{
  pkgs,
  myModulesPath,
  ...
}: {
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

    # DHCP config for the runtime desktop session only (NetworkManager).
    # The initrd below keeps its own static IPv4 setup.
    networkmanager.ensureProfiles.profiles."lan" = {
      connection = {
        id = "lan";
        type = "ethernet";
        interface-name = "eno1";
        # Outrank any auto-created "Wired connection N" profile
        autoconnect-priority = 100;
      };
      ethernet = { };
      ipv4.method = "auto"; # DHCPv4 at runtime
      ipv6.method = "auto";
      ipv6.addr-gen-mode = "stable-privacy";
    };
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
      networkConfig.IPv6AcceptRA = false; # IPv6 off in initrd, comes up with NM at runtime
      linkConfig.RequiredForOnline = "routable";
    };

    wait-online.enable = false;
  };

  systemd.network.wait-online.enable = false;

  # The initrd's static config leaves eno1 "externally managed" when NM starts;
  # NM then *assumes* it as an in-memory connection named "eno1" and never
  # autoconnects the declarative profile over it. Activating "lan" explicitly
  # replaces the assumed connection with our managed DHCP profile.
  systemd.services.nm-takeover-lan = {
    description = "Activate the declarative lan profile on eno1";
    wantedBy = [ "multi-user.target" ];
    after = [
      "NetworkManager.service"
      "NetworkManager-ensure-profiles.service"
    ];
    path = [ pkgs.networkmanager ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.networkmanager}/bin/nmcli --wait 30 connection up lan";
    };
  };

  system.stateVersion = "25.05";
}
