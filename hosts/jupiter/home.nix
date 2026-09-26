{
  myModulesPath,
  pkgs,
  outputs,
  lib,
  ...
}: let
  run-nixos-vm = lib.getExe outputs.nixosConfigurations.microvm.config.system.build.vm;

  nixos-sandbox = pkgs.writeShellScriptBin "run-nixos-sandbox" ''
    set -e

    TEMPDIR=$(mktemp -d /tmp/sandbox.XXXXXX)
    trap 'rm -rf -- "$TEMPDIR"' EXIT

    export NIX_DISK_IMAGE="''$TEMPDIR/root.qcow2"

    SANDBOX_SSH_PORT=60000
    MAX_RETRIES=10

    while true; do
        export SANDBOX_SSH_PORT
        export QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:''${SANDBOX_SSH_PORT}-:22"

        set +e
        ${run-nixos-vm} 2>"$TEMPDIR/qemu.err"
        exit_code=$?
        set -e

        # If QEMU exits cleanly (e.g. VM shutdown), propagate success
        if [ "$exit_code" -eq 0 ]; then
            exit 0
        fi

        # If it's the specific port-forwarding failure, try next port
        if [ "$exit_code" -eq 1 ] && grep -q "Could not set up host forwarding rule" "$TEMPDIR/qemu.err"; then
            MAX_RETRIES=$((MAX_RETRIES - 1))
            if [ "$MAX_RETRIES" -le 0 ]; then
                echo "Ran out of ports to try for QEMU hostfwd" >&2
                cat "$TEMPDIR/qemu.err" >&2
                exit 1
            fi
            SANDBOX_SSH_PORT=$((SANDBOX_SSH_PORT + 1))
            continue
        fi

        # Any other error: show stderr and exit with original code
        cat "$TEMPDIR/qemu.err" >&2
        exit "$exit_code"
    done
  '';
in {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd ~/projects/nixos-config && sudo nixos-rebuild switch --log-format internal-json -v --flake .#jupiter &| nom --json";
    "build" = "cd ~/projects/nixos-config && nixos-rebuild build --log-format internal-json -v --flake .#jupiter &| nom --json";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank | nvim";
  };

  home.packages = [
    nixos-sandbox
  ];

  home.stateVersion = "24.11";
}
