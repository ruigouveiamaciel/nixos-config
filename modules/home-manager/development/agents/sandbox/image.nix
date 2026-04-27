{pkgs, ...}: let
  # `dockerTools` only produces Linux images. Pin the build to the matching
  # Linux system so darwin hosts dispatch the whole derivation to the
  # remote Linux builder (saturn) instead of trying to evaluate Linux
  # derivations natively. On a Linux host this is a no-op.
  linuxSystem =
    if pkgs.stdenv.hostPlatform.isAarch64
    then "aarch64-linux"
    else "x86_64-linux";

  pkgs' =
    if pkgs.stdenv.hostPlatform.isLinux
    then pkgs
    else
      import pkgs.path {
        system = linuxSystem;
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

    # ── language runtimes ───────────────────────────────────────────────
    nodejs_24
    pnpm
    go
  ];
in
  # `streamLayeredImage` returns a script that emits the image tarball on
  # stdout, so we never materialise a multi-GB tar in /nix/store. Pipe it
  # straight into `podman load` (or `skopeo copy docker-archive:/dev/stdin …`).
  # Both the build-time helpers and the contents come from `pkgs'` (Linux),
  # so everything is consistent and the build is offloaded to saturn.
  pkgs'.dockerTools.streamLayeredImage {
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
      ]
      ++ toolbelt;

    maxLayers = 128;

    config = {
      Cmd = ["/bin/bash" "-l"];
      WorkingDir = "/home/agent";
      User = "agent";
      Env = [];
    };
  }
