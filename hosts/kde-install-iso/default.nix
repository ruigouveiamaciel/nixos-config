{
  lib,
  modulesPath,
  myModulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/desktop/plasma6.nix"
    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/users/smokewow"
    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/networkmanager.nix"
  ];

  home-manager.users.smokewow.imports = [./home.nix];

  boot = {
    supportedFilesystems = ["zfs"];
    zfs = {
      devNodes = "/dev/disk/by-partlabel";
    };
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  services.displayManager.autoLogin.user = lib.mkForce "smokewow";

  networking = {
    hostName = lib.mkForce "pluto";
  };

  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
