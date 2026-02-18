{
  lib,
  modulesPath,
  myModulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/desktop/plasma6.nix"
    "${myModulesPath}/users/rui"
    "${myModulesPath}/networking/openssh.nix"
  ];

  home-manager.users.rui.imports = [./home.nix];

  boot = {
    supportedFilesystems = ["zfs"];
    zfs = {
      package = pkgs.zfs_2_4;
      devNodes = "/dev/disk/by-partlabel";
    };
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  services.displayManager.autoLogin.user = lib.mkForce "rui";
  services.openssh.settings = {
    PasswordAuthentication = lib.mkForce true;
    PermitRootLogin = lib.mkForce "yes";
  };

  networking = {
    hostName = lib.mkForce "pluto";
    useDHCP = lib.mkForce true;
  };

  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
