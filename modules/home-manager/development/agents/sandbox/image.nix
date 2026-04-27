{
  pkgs,
  inputs,
  ...
}: let
  linuxSystem =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "aarch64-linux"
    else "x86_64-linux";

  pkgs' = import pkgs.path {
    system = linuxSystem;
    config.allowUnfree = false;
    overlays = builtins.attrValues (import ../../../../../overlays {inherit inputs;});
  };

  toolbelt = with pkgs'; [
    # shell
    bashInteractive
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    diffutils
    patch
    which

    # pagers / inspection
    less
    file
    tree

    # archives
    gnutar
    gzip
    unzip

    # network & TLS
    curl
    wget
    openssh

    # fast search
    fd
    ripgrep

    # data wrangling
    jq
    yq-go

    # VCS
    git

    # build / scripting
    gnumake
    python3

    # language runtimes
    nodejs_24
    pnpm
    go

    # editors
    myNeovim
  ];

  # pi configuration
  piAgentConfigSrc = pkgs.lib.cleanSourceWith {
    name = "pi-agent-config-src";
    src = ../pi;
    filter = path: _type: let
      baseName = baseNameOf (toString path);
    in
      !(builtins.elem baseName [
        "node_modules"
      ]);
  };

  piAgentConfigNodeModules = pkgs'.importNpmLock.buildNodeModules {
    npmRoot = piAgentConfigSrc;
    nodejs = pkgs'.nodejs_24;
  };

  piAgentConfig = pkgs'.runCommand "pi-agent-config" {} ''
    dest=$out/home/agent/.pi/agent
    mkdir -p "$dest"
    cp -rL ${piAgentConfigSrc}/. "$dest/"
    cp -rL ${piAgentConfigNodeModules}/node_modules "$dest/node_modules"

    # Shell aliases for the agent user.
    cat > $out/home/agent/.bashrc <<'EOF'
    alias pi='npx -y @mariozechner/pi-coding-agent@0.70.2'
    EOF
    cat > $out/home/agent/.bash_profile <<'EOF'
    [ -f ~/.bashrc ] && . ~/.bashrc
    EOF

    # pnpm configuration. The store/cache are bind-mounted from the host
    # so packages are reused across host and container. Hard-linking does
    # not work across separate virtiofs bind mounts, so force copy mode
    # to avoid noisy fallbacks.
    mkdir -p $out/home/agent/.local/share/pnpm/store \
             $out/home/agent/.cache/pnpm
    cat > $out/home/agent/.npmrc <<'EOF'
    store-dir=/home/agent/.local/share/pnpm/store
    cache-dir=/home/agent/.cache/pnpm
    package-import-method=copy
    EOF

    chmod -R u+w $out/home/agent
  '';
in
  pkgs.dockerTools.streamLayeredImage {
    name = "agent-sandbox";
    tag = "latest";

    contents =
      [
        pkgs'.dockerTools.binSh
        pkgs'.dockerTools.usrBinEnv
        pkgs'.dockerTools.caCertificates
        (pkgs'.dockerTools.fakeNss.override {
          extraPasswdLines = [
            "agent:x:1000:1000:agent:/home/agent:${pkgs'.bashInteractive}/bin/bash"
          ];
          extraGroupLines = ["agent:x:1000:"];
        })
        piAgentConfig
      ]
      ++ toolbelt;

    maxLayers = 128;

    fakeRootCommands = ''
      chown -R 1000:1000 home/agent
      mkdir -p tmp
      chmod 1777 tmp
    '';

    config = {
      Cmd = ["/bin/bash" "-l"];
      WorkingDir = "/home/agent";
      User = "agent";
      Env = [];
    };
  }
