{
  myModulesPath,
  lib,
  config,
  ...
}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/users/rui"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/networking/remote-disk-unlock.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"

    ./filesystem.nix
    ./hardware-configuration.nix

    ./services
  ];

  home-manager.users.rui.imports = [./home.nix];
  networking = {
    hostName = "saturn";
    hostId = "b0d87d98";
    useDHCP = false;
    enableIPv6 = false;
    defaultGateway = {
      address = "10.0.50.1";
      interface = "enp90s0";
    };
    nameservers = ["10.0.50.1"];
    interfaces.enp90s0 = {
      ipv4.addresses = [
        {
          address = "10.0.50.42";
          prefixLength = 24;
        }
        {
          address = "10.0.50.10";
          prefixLength = 24;
        }
        {
          address = "10.0.50.200";
          prefixLength = 24;
        }
      ];
    };
  };

  services.openssh.listenAddresses = [
    {
      addr = "10.0.50.42";
      port = 22;
    }
  ];

  boot = {
    kernelParams = ["ip=10.0.50.42::10.0.50.1:255.255.255.0:saturn:enp90s0:off:10.0.50.1::"];

    loader.systemd-boot = {
      enable = true;
      configurationLimit = 7;
    };

    # Don't hang boot because of network timeout
    initrd.systemd.network.wait-online.enable = false;
  };

  time.timeZone = "Etc/UTC";
  systemd.network.wait-online.enable = false;

  systemd.services = lib.attrsets.mapAttrs' (_: {serviceName, ...}:
    lib.attrsets.nameValuePair serviceName {
      serviceConfig = {
        # Required to for rootless containers to work with sdnotify=conmon
        # Already been fixed for 26.05, merge for backport to 25.11 was not
        # merged
        Delegate = true;
      };
    })
  config.virtualisation.oci-containers.containers;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";
}
