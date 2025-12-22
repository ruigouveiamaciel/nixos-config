{myModulesPath, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix

    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/desktop/gaming"
    "${myModulesPath}/desktop/plasma6.nix"

    "${myModulesPath}/users/rui"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"

    ../saturn/services
  ];

  home-manager.users.rui.imports = [./home.nix];

  networking = {
    hostName = "gaming-desktop";
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

  boot.postBootCommands = ''
    mkdir -p /persist/media/{movies,tvshows,anime,test,personal,music}
    chown -R nobody:nogroup /persist/media
    chmod -R 766 /persist/media
  '';

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
