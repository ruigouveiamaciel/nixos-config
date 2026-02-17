{
  lib,
  modulesPath,
  myModulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    # "${modulesPath}/installer/cd-dvd/latest-kernel.nix"

    "${myModulesPath}/desktop/plasma6.nix"
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/users/rui"
    "${myModulesPath}/networking/openssh.nix"
  ];

  home-manager.users.rui.imports = [./home.nix];

  boot = {
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-partlabel";
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  services.displayManager.autoLogin.user = lib.mkForce "rui";

  networking = {
    hostName = lib.mkForce "pluto";
    useDHCP = lib.mkForce true;
  };

  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
