{
  pkgs,
  lib,
}: let
  # `dockerTools` only produces Linux images. When the host isn't already
  # Linux we cross-compile: builds run locally (no remote Linux builder
  # required) and emit Linux ELF binaries. Pure-substitution from cache.nixos
  # also works because cross store paths are realised by Hydra for the common
  # `pkgsCross.*` attrsets.
  crossLinuxSystem =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "aarch64-linux"
    else "x86_64-linux";

  pkgs' =
    if pkgs.stdenv.hostPlatform.isLinux
    then pkgs
    else
      import pkgs.path {
        localSystem = {system = pkgs.stdenv.hostPlatform.system;};
        crossSystem = {system = crossLinuxSystem;};
        config.allowUnfree = true;
      };

  toolbelt = with pkgs'; [
    # ── shell + core userland ───────────────────────────────────────────
    bashInteractive

    # ── network & TLS ───────────────────────────────────────────────────
    curl
    wget
    openssh

    # ── search / navigation ─────────────────────────────────────────────
    fd

    # ── data wrangling ──────────────────────────────────────────────────
    jq

    # ── VCS ─────────────────────────────────────────────────────────────
    git

    # ── build toolchain ─────────────────────────────────────────────────

    # ── language runtimes ───────────────────────────────────────────────
    nodejs_24
    pnpm
    go

    # ── editor ──────────────────────────────────────────────────────────
    # myNeovim
  ];
in
  # `streamLayeredImage` returns a script that emits the image tarball on
  # stdout, so we never materialise a multi-GB tar in /nix/store. Pipe it
  # straight into `podman load` (or `skopeo copy docker-archive:/dev/stdin …`).
  # IMPORTANT: build the image with the *native* `dockerTools` (so build-time
  # helpers run on the host) but populate it with *cross-compiled* Linux
  # store paths. Mixing these is what avoids "can't run aarch64-linux
  # executables" while still producing a valid Linux image.
  pkgs.dockerTools.streamLayeredImage {
    name = "agent-sandbox";
    tag = "latest";

    contents =
      [
        pkgs'.dockerTools.binSh
        pkgs'.dockerTools.usrBinEnv
        pkgs'.dockerTools.caCertificates
        (pkgs'.dockerTools.fakeNss.override
          {
            extraPasswdLines = [
              "agent:x:1000:1000:agent:/home/agent:${pkgs'.bashInteractive}/bin/bash"
            ];
            extraGroupLines = ["agent:x:1000:"];
          })
      ]
      ++ (lib.filter (x: x != null) toolbelt);

    maxLayers = 128;

    # fakeRootCommands = ''
    #   mkdir -p home/agent tmp root
    #   chmod 1777 tmp
    # '';
    # enableFakechroot = true;

    config = {
      Cmd = ["/bin/bash" "-l"];
      WorkingDir = "/home/agent";
      User = "agent";
      Env = [];
    };
  }
