{myModulesPath, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"

    "${myModulesPath}/desktop/kde.nix"
    "${myModulesPath}/desktop/gaming"
    "${myModulesPath}/desktop/voyager.nix"

    "${myModulesPath}/users/smokewow"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"
  ];

  home-manager.users.smokewow.imports = [./home.nix];

  virtualisation.docker.enable = true;

  networking = {
    hostName = "jupiter";
    hostId = "397d7c75";
    useDHCP = true;
  };

  boot = {
    plymouth.enable = true;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
    };
  };

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
