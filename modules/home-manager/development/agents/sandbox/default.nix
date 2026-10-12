{myLib, ...}: let
  sandbox-system = myLib.mkSystem ./system.nix;
  run-sandbox-vm = sandbox-system.config.system.build.vm;
  # run-sandbox-test = pkgs.writeShellScriptBin "run-sandbox-test" ''
  #   set -e
  #
  #   TEMPDIR=$(mktemp -d /tmp/sandbox.XXXXXX)
  #   trap 'rm -rf -- "$TEMPDIR"' EXIT
  #   chmod 700 "$TEMPDIR"
  #
  #   export NIX_DISK_IMAGE="$TEMPDIR/root.qcow2"
  #
  #   export QEMU_OPTS="-chardev socket,id=qga0,path=$TEMPDIR/qga.sock,server=on,wait=off \
  #   -device virtio-serial \
  #   -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"
  #
  #   ${lib.getExe run-sandbox-vm}
  # '';
in {
  home.packages = [
    run-sandbox-vm
  ];
}
