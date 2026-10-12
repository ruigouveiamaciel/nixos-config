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
  users.users.smokewow.hashedPasswordFile = "/persist/smokewow-hashed-password-file";

  services.displayManager.autoLogin = {
    enable = true;
    user = "smokewow";
  };

  networking = {
    hostName = "jupiter";
    hostId = "397d7c75";
  };

  boot.initrd.systemd.network = {
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      address = ["10.0.0.42/24"];
      routes = [
        {
          Gateway = "10.0.0.1";
          Destination = "0.0.0.0/0";
        }
      ];
      dns = ["10.0.0.1"];
      networkConfig.IPv6AcceptRA = false;
      linkConfig.RequiredForOnline = "routable";
    };

    wait-online.enable = false;
  };

  systemd.network.wait-online.enable = false;

  system.stateVersion = "25.05";
}
