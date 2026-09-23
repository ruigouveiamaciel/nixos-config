{myModulesPath, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"

    "${myModulesPath}/desktop/plasma6.nix"
    "${myModulesPath}/desktop/gaming"

    "${myModulesPath}/locales/pt-pt.nix"
    "${myModulesPath}/users/smokewow"

    "${myModulesPath}/networking/networkmanager.nix"
    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"
    "${myModulesPath}/security/pam-u2f-auth.nix"

    "${myModulesPath}/boot/plymouth.nix"
    "${myModulesPath}/boot/systemd-boot.nix"
  ];

  home-manager.users.smokewow.imports = [./home.nix];

  networking = {
    hostName = "jupiter";
    hostId = "397d7c75";
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
