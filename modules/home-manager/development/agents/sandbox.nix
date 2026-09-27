{
  pkgs,
  lib,
  outputs,
  ...
}: let
  run-nixos-vm = lib.getExe outputs.nixosConfigurations.sandbox.config.system.build.vm;
  nixos-sandbox = pkgs.writeShellScriptBin "run-nixos-sandbox" ''
    set -e

    TEMPDIR=$(mktemp -d /tmp/sandbox.XXXXXX)
    trap 'rm -rf -- "$TEMPDIR"' EXIT

    export NIX_DISK_IMAGE="$TEMPDIR/root.qcow2"
    SANDBOX_SSH_PORT="''${SANDBOX_SSH_PORT:-60000}"

    export QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:''${SANDBOX_SSH_PORT}-:22"

    set +e
    ${run-nixos-vm} -no-reboot 2>"$TEMPDIR/qemu.err"
    exit_code=$?
    set -e

    if [ "$exit_code" -eq 0 ]; then
        exit 0
    fi

    if [ "$exit_code" -eq 1 ] && grep -q "Could not set up host forwarding rule" "$TEMPDIR/qemu.err"; then
        cat "$TEMPDIR/qemu.err" >&2
        exit 69
    fi

    cat "$TEMPDIR/qemu.err" >&2
    exit 1
  '';
in {
  home.packages = with pkgs; [
    qemu
    sshpass
    nixos-sandbox
  ];
}
