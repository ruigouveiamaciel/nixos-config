{
  config,
  lib,
  ...
}: {
  imports = [../minimal-vm];

  networking.hostName = "media-management";

  services.rpcbind.enable = true;
  fileSystems = {
    "/mnt/media" = {
      device = "10.0.102.3:/media";
      fsType = "nfs";
      options = ["nfsvers=4.2"];
    };
    "/mnt/torrenting" = {
      device = "10.0.102.3:/torrenting";
      fsType = "nfs";
      options = ["nfsvers=4.2"];
    };
  };

  virtualisation.oci-containers.containers = {
    radarr = {
      image = "linuxserver/radarr@sha256:620189d67078ddcfeb7a4efa424eb62f827ef734ef1e56980768bf8efd73782a";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/torrenting/.radarr:/config"
        "/mnt/torrenting/downloads:/downloads"
        "/mnt/media/movies:/movies"
      ];
    };
    bazarr = {
      image = "linuxserver/bazarr@sha256:36f4ba69ab5bfb32c384ea84cf0036b8b6e07fb9a7ab65885f3619de2a8318f8";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/torrenting/.bazarr:/config"
        "/mnt/media/shows:/shows"
        "/mnt/media/movies:/movies"
      ];
    };
    prowlarr = {
      image = "linuxserver/prowlarr@sha256:761f73534a01aec4bf72a1396e9b9fda3f01632948b3fa31985982d26120a330";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/torrenting/.prowlarr:/config"
      ];
    };
    sonarr = {
      image = "linuxserver/sonarr@sha256:49a8e636fd4514b23d37c84660101fecbb632174ba0569e0f09bbd2659a2a925";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/torrenting/.sonarr:/config"
        "/mnt/torrenting/downloads:/downloads"
        "/mnt/media/shows:/shows"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      7878 # Radarr
      6767 # Bazarr
      9696 # Prowlarr
      8989 # Sonarr
    ];
  };

  systemd.services = let
    inherit (config.virtualisation.oci-containers) backend;
  in
    lib.attrsets.mapAttrs' (serviceName: _:
      lib.attrsets.nameValuePair "${backend}-${serviceName}" {
        bindsTo = ["mnt-torrenting.mount"];
        after = ["mnt-torrenting.mount"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      })
    config.virtualisation.oci-containers.containers;
}
