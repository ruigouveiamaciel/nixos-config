{
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"

    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  swapDevices = lib.mkImageMediaOverride [];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;

  myNixOS = {
    locales.pt-pt.enable = true;
    networking.openssh.enable = true;
    security.disable-lecture.enable = true;
    nix = {
      nix-settings.enable = true;
      sops.enable = true;
    };
    users.authorized-keys.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = config.myNixOS.users.authorized-keys.users.rui;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/installation-device.nix
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";
  networking.firewall.logRefusedConnections = false;
  environment.etc."systemd/pstore.conf".text = ''
    [PStore]
    Unlink=no
  '';
  system.nixos.variant_id = lib.mkDefault "installer";
  documentation.enable = lib.mkImageMediaOverride false;
  documentation.nixos.enable = lib.mkImageMediaOverride false;

  networking = {
    hostName = lib.mkForce "minimal-live-iso";
    useDHCP = lib.mkForce true;
  };

  services.qemuGuest.enable = true;
  zramSwap.enable = true;
  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
