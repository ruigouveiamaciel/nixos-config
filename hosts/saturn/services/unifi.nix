{
  inputs,
  outputs,
  myModulesPath,
  ...
}: {
  containers.unifi = {
    autoStart = true;
    additionalCapabilities = ["CAP_NET_BIND_SERVICE"];
    macvlans = ["enp90s0"];
    bindMounts."/var/lib/unifi/data" = {
      hostPath = "/persist/services/unifi";
      isReadOnly = false;
    };
    specialArgs = {
      inherit inputs outputs myModulesPath;
    };
    config = {
      pkgs,
      myModulesPath,
      ...
    }: {
      imports = [
        "${myModulesPath}/system/nixpkgs.nix"
      ];

      networking = {
        firewall.allowedTCPPorts = [8443];
        interfaces."mv-enp90s0" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.0.50.253";
              prefixLength = 24;
            }
          ];
        };
        defaultGateway = "10.0.50.1";
        nameservers = ["10.0.50.1"];
        useHostResolvConf = false;
      };

      services.unifi = {
        enable = true;
        unifiPackage = pkgs.unstable.unifi;
        openFirewall = true;
      };

      system.stateVersion = "25.11";
    };
  };
}
