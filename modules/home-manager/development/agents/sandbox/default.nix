{pkgs, ...}: let
  # Content-addressed tag derived from the streamLayeredImage script's
  # /nix/store hash — changes iff the image contents change. Lets us skip
  # `podman load` when the image is already present locally.
  imageTag = builtins.substring 0 16 (baseNameOf pkgs.agent-sandbox.outPath);
  imageRef = "agent-sandbox:${imageTag}";

  # Per-OS host paths for pnpm's content-addressable store and HTTP cache.
  # These get bind-mounted into the canonical Linux locations inside the
  # container so the host and the sandbox share downloaded packages.
  hostPnpmStore =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/pnpm/store"
    else ".local/share/pnpm/store";
  hostPnpmCache =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Caches/pnpm"
    else ".cache/pnpm";

  # A stable container name tied to the image version. When the image
  # changes, a new container is created; otherwise the same container
  # (and therefore its writable layer + filesystem state) is reused
  # across invocations.
  containerName = "agent-sandbox-${imageTag}";

  agent-sandbox = pkgs.writeShellScriptBin "agent-sandbox" ''
    set -euo pipefail
    if ! podman image exists ${imageRef}; then
      ${pkgs.agent-sandbox} | podman load >/dev/null
      podman tag agent-sandbox:latest ${imageRef}
    fi

    if ! podman container exists ${containerName}; then
      mounts=()
      [ -d "$HOME/projects" ] && mounts+=(-v "$HOME/projects:/home/agent/projects:rw")
      for f in auth.json models.json; do
        [ -f "$HOME/.pi/agent/$f" ] && mounts+=(-v "$HOME/.pi/agent/$f:/home/agent/.pi/agent/$f:ro")
      done

      # Share pnpm store + cache with the host (creating them if missing).
      mkdir -p "$HOME/${hostPnpmStore}" "$HOME/${hostPnpmCache}"
      mounts+=(-v "$HOME/${hostPnpmStore}:/home/agent/.local/share/pnpm/store:rw")
      mounts+=(-v "$HOME/${hostPnpmCache}:/home/agent/.cache/pnpm:rw")
      podman create \
        -it \
        --name ${containerName} \
        "''${mounts[@]}" \
        ${imageRef} "$@" >/dev/null
    fi

    exec podman start -ai ${containerName}
  '';
in {
  home.packages = [agent-sandbox];

  programs.fish.shellAliases = {
    # Short form: `as` → drop into the agent sandbox.
    "as" = "agent-sandbox";
  };
}
