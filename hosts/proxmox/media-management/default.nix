{
  config,
  lib,
  ...
}: let
  services = config.myNixOS.services.discovery.default;
in {
  imports = [../minimal-vm];

  networking.hostName = "media-management";

  fileSystems = {
    "/mnt/downloads" = {
      device = "${services.nfs.ip}:/downloads";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/movies" = {
      device = "${services.nfs.ip}:/media/movies";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/tvshows" = {
      device = "${services.nfs.ip}:/media/tvshows";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/anime" = {
      device = "${services.nfs.ip}:/media/anime";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/radarr" = {
      device = "${services.nfs.ip}:/services/radarr";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/sonarr" = {
      device = "${services.nfs.ip}:/services/sonarr";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/bazarr" = {
      device = "${services.nfs.ip}:/services/bazarr";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/prowlarr" = {
      device = "${services.nfs.ip}:/services/prowlarr";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/jellyseerr" = {
      device = "${services.nfs.ip}:/services/jellyseerr";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
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
        "/mnt/radarr:/config"
        "/mnt/downloads:/downloads"
        "/mnt/movies:/data/movies"
      ];
    };
    bazarr = {
      image = "linuxserver/bazarr@sha256:36f4ba69ab5bfb32c384ea84cf0036b8b6e07fb9a7ab65885f3619de2a8318f8";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/bazarr:/config"
        "/mnt/tvshows:/data/tvshows"
        "/mnt/anime:/data/anime"
        "/mnt/movies:/data/movies"
      ];
    };
    prowlarr = {
      image = "linuxserver/prowlarr@sha256:761f73534a01aec4bf72a1396e9b9fda3f01632948b3fa31985982d26120a330";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/prowlarr:/config"
      ];
    };
    sonarr = {
      image = "linuxserver/sonarr@sha256:49a8e636fd4514b23d37c84660101fecbb632174ba0569e0f09bbd2659a2a925";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/sonarr:/config"
        "/mnt/downloads:/downloads"
        "/mnt/tvshows:/data/tvshows"
        "/mnt/anime:/data/anime"
      ];
    };
    jellyseerr = {
      image = "fallenbagel/jellyseerr@sha256:52ca0b18c58ec4e769b8acae9beaae37a520a365c7ead52b7fc3ba1c3352d1f0";
      extraOptions = ["--network=host"];
      environment = {
        TZ = "Etc/UTC";
      };
      volumes = [
        "/mnt/jellyseerr:/app/config"
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
      5055 # Jellyseerr
    ];
  };

  systemd.services = lib.attrsets.mapAttrs' (_: {serviceName, ...}:
    lib.attrsets.nameValuePair serviceName rec {
      bindsTo = [
        "mnt-downloads.mount"
        "mnt-movies.mount"
        "mnt-tvshows.mount"
        "mnt-anime.mount"
        "mnt-radarr.mount"
        "mnt-sonarr.mount"
        "mnt-bazarr.mount"
        "mnt-prowlarr.mount"
        "mnt-jellyseerr.mount"
      ];
      after = bindsTo;
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 60;
      };
    })
  config.virtualisation.oci-containers.containers;
}
