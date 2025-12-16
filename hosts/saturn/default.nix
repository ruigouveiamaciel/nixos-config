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

    ./services/bazarr.nix
    ./services/sonarr.nix
    ./services/radarr.nix
    ./services/prowlarr.nix
    ./services/jellyseerr.nix
    ./services/flood.nix
    ./services/qbittorrent.nix
    ./services/jellyfin.nix

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

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    oci-containers.backend = "podman";
  };

  systemd.services =
    lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName {
        after = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") ["setup-podman-networks.service"];
        requires = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") ["setup-podman-networks.service"];
        serviceConfig = {
          RestartSec = 60;
          StartLimitIntervalSec = 3600;
          StartLimitBurst = 60;
        };
      })
    config.virtualisation.oci-containers.containers
    // {
      setup-podman-networks = let
        podman = "${config.virtualisation.podman.package}/bin/podman";
      in
        lib.mkIf (config.virtualisation.oci-containers.backend == "podman") {
          after = ["podman.service"];
          requires = ["podman.service"];
          wantedBy = ["multi-user.target"];
          script = ''
            ${podman} network exists podman-internal || \
            ${podman} network create --internal podman-internal
            ${podman} network exists podman-hostnet || \
            ${podman} network create --driver macvlan --subnet 10.0.50.0/24 --gateway 10.0.50.1 --opt parent=enp90s0 podman-hostnet
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };
    };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";
}
