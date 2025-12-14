{
  lib,
  modulesPath,
  myModulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${modulesPath}/installer/cd-dvd/latest-kernel.nix"

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/users/rui"
    "${myModulesPath}/networking/openssh.nix"
  ];

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
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
