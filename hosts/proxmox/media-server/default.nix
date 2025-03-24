{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  IMMICH_VERSION = "v1.129.0";
  services = config.myNixOS.services.discovery.default;
in {
  imports = [
    ../minimal-vm

    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  networking.hostName = "media-server";

  hardware = {
    intelgpu = {
      driver = "xe";
      vaapiDriver = "intel-media-driver";
    };
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot = {
    kernelParams = [
      "i915.force_probe=46a6"
      "i915.modeset=1"
      "i915.enable_guc=2"
    ];
    kernelPackages = pkgs.unstable.linuxPackages_latest;
  };

  fileSystems = {
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
    "/mnt/movies" = {
      device = "${services.nfs.ip}:/media/movies";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/personal" = {
      device = "${services.nfs.ip}:/media/personal";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/jellyfin" = {
      device = "${services.nfs.ip}:/services/jellyfin";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
    "/mnt/immich" = {
      device = "${services.nfs.ip}:/services/immich";
      fsType = "nfs";
      options = ["nfsvers=4.2" "bg" "noatime"];
    };
  };

  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "linuxserver/jellyfin@sha256:0b793d24dc3ec861e205ec3aceebe4021180d38a2f461522f1d83d992d4f053a";
      extraOptions = ["--device=/dev/dri:/dev/dri"];
      environment = {
        TZ = "Etc/UTC";
        JELLYFIN_PublishedServerUrl = services.jellyfin.http;
        JELLYFIN_CACHE_DIR = "/cache";
      };
      ports = ["8096:8096"];
      volumes = [
        "/mnt/jellyfin:/config"
        "/mnt/jellyfin-cache:/cache"
        "/mnt/movies:/data/movies"
        "/mnt/tvshows:/data/tvshows"
        "/mnt/anime:/data/anime"
        "/mnt/personal:/data/personal"
      ];
    };
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:${IMMICH_VERSION}";
      extraOptions = [
        "--network=immich"
        "--network=podman"
        "--device=/dev/dri:/dev/dri"
        "--no-healthcheck"
      ];
      environmentFiles = [config.sops.templates."immich.env".path];
      ports = ["2283:2283"];
      volumes = [
        "/mnt/immich/files:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      dependsOn = [
        "immich-redis"
        "immich-database"
      ];
    };
    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION}-openvino";
      extraOptions = [
        "--network=immich"
        "--network=podman"
        "--device=/dev/dri:/dev/dri"
        "--no-healthcheck"
      ];
      environmentFiles = [config.sops.templates."immich.env".path];
    };
    immich-redis = {
      hostname = "redis";
      image = "docker.io/redis:6.2-alpine@sha256:148bb5411c184abd288d9aaed139c98123eeb8824c5d3fce03cf721db58066d8";
      extraOptions = [
        "--network=immich"
        "--health-cmd"
        "redis-cli ping || exit 1"
      ];
    };
    immich-database = {
      hostname = "database";
      image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:739cdd626151ff1f796dc95a6591b55a714f341c737e27f045019ceabf8e8c52";
      user = "nobody:nogroup";
      extraOptions = [
        "--network=immich"
        "--health-cmd"
        ''pg_isready --dbname="''${POSTGRES_DB}" --username="''${POSTGRES_USER}" || exit 1; Chksum="''$(psql --dbname="''${POSTGRES_DB}" --username="''${POSTGRES_USER}" --tuples-only --no-align --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')"; echo "checksum failure count is $$Chksum"; [ "''$Chksum" = '0' ] || exit 1''
        "--health-interval"
        "5m"
        "--health-startup-interval"
        "30s"
        "--health-start-period"
        "5m"
      ];
      environmentFiles = [config.sops.templates."immich.env".path];
      volumes = [
        "/mnt/immich/database:/var/lib/postgresql/data"
      ];
      cmd = [
        "postgres"
        "-c"
        "shared_preload_libraries=vectors.so"
        "-c"
        ''search_path="''$user", public, vectors''
        "-c"
        "logging_collector=on"
        "-c"
        "max_wal_size=2GB"
        "-c"
        "shared_buffers=512MB"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8096 2283];
  };

  systemd.services =
    (lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName rec {
        bindsTo = [
          "mnt-movies.mount"
          "mnt-anime.mount"
          "mnt-tvshows.mount"
          "mnt-personal.mount"
          "mnt-jellyfin.mount"
          "mnt-immich.mount"
          "run-secrets.d.mount"
          "create-immich-network.service"
        ];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
      })
    config.virtualisation.oci-containers.containers)
    // {
      create-immich-network = {
        after = ["podman.service"];
        script = ''
          ${pkgs.podman}/bin/podman network exists immich || \
          ${pkgs.podman}/bin/podman network create --internal immich
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };

  sops = {
    secrets = {
      immich-database-password.sopsFile = ./secrets.yaml;
    };

    templates."immich.env" = {
      restartUnits = [
        "${config.virtualisation.oci-containers.containers.immich-database.serviceName}.service"
        "${config.virtualisation.oci-containers.containers.immich-server.serviceName}.service"
        "${config.virtualisation.oci-containers.containers.immich-machine-learning.serviceName}.service"
      ];
      content = ''
        TZ=Etc/UTC
        IMMICH_VERSION=${IMMICH_VERSION}
        IMMICH_LOG_LEVEL=verbose

        DB_USERNAME=postgres
        DB_DATABASE_NAME=immich
        DB_PASSWORD=${config.sops.placeholder.immich-database-password}

        POSTGRES_PASSWORD=${config.sops.placeholder.immich-database-password}
        POSTGRES_USER=postgres
        POSTGRES_DB=immich
        POSTGRES_INITDB_ARGS="--data-checksums"
        PGDATA=/var/lib/postgresql/data/pgdata
      '';
    };
  };
}
