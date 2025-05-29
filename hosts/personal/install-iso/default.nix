{
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${modulesPath}/installer/cd-dvd/latest-kernel.nix"
  ];

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  myNixOS = {
    profiles = {
      essentials.enable = true;
    };
    users.rui.enable = true;
    networking.openssh.enable = true;
  };

  services.displayManager.autoLogin.user = lib.mkForce "rui";

  networking = {
    hostName = lib.mkForce "install-iso";
    useDHCP = lib.mkForce true;
  };

  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
