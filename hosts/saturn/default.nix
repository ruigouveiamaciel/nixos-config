{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/users/rui"

    "${myModulesPath}/networking/openssh.nix"
    "${myModulesPath}/security/pam-ssh-agent-auth.nix"

    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  home-manager.users.rui.imports = [./home.nix];

  networking = {
    hostName = "saturn";
    hostId = "b0d87d98";
    useDHCP = true;
    enableIPv6 = false;
    firewall.interfaces."podman+" = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 7;
  };

  time.timeZone = "Etc/UTC";

  # Don't hang boot because of network timeout
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";
}
