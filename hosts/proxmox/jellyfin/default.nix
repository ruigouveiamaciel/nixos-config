{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  IMMICH_VERSION = "v1.129.0";
in {
  imports = [
    ../minimal-vm

    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  networking.hostName = "jellyfin";

  hardware = {
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

  services.rpcbind.enable = true;
  fileSystems."/mnt/media" = {
    device = "10.0.102.3:/media";
    fsType = "nfs";
    options = ["nfsvers=4.2"];
  };

  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "linuxserver/jellyfin@sha256:0b793d24dc3ec861e205ec3aceebe4021180d38a2f461522f1d83d992d4f053a";
      extraOptions = ["--device=/dev/dri:/dev/dri"];
      environment = {
        TZ = "Etc/UTC";
      };
      ports = ["8096:8096"];
      volumes = [
        "/mnt/media/.jellyfin:/config"
        "/mnt/media/movies:/data/movies"
        "/mnt/media/shows:/data/shows"
      ];
    };
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:${IMMICH_VERSION}";
      extraOptions = ["--device=/dev/dri:/dev/dri" "--no-healthcheck"];
      environmentFiles = [config.sops.templates."immich.env".path];
      ports = ["2283:2283"];
      volumes = [
        "/mnt/media/personal:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      dependsOn = [
        "immich-redis"
        "immich-database"
      ];
    };
    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION}-openvino";
      extraOptions = ["--device=/dev/dri:/dev/dri" "--no-healthcheck"];
      environmentFiles = [config.sops.templates."immich.env".path];
    };
    immich-redis = {
      image = "docker.io/redis:6.2-alpine@sha256:148bb5411c184abd288d9aaed139c98123eeb8824c5d3fce03cf721db58066d8";
      extraOptions = ["--health-cmd" "redis-cli ping || exit 1"];
    };
    immich-database = {
      image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:739cdd626151ff1f796dc95a6591b55a714f341c737e27f045019ceabf8e8c52";
      extraOptions = [
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
        "/mnt/media/.immich/database:/var/lib/postgresql/data"
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
        "-c wal_compression=on"
      ];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8096 2283];
  };

  systemd.services = lib.attrsets.mapAttrs' (_: {serviceName, ...}:
    lib.attrsets.nameValuePair serviceName {
      bindsTo = ["mnt-media.mount"];
      after = ["mnt-media.mount"];
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 60;
      };
      startLimitBurst = 60;
      startLimitIntervalSec = 3600;
    })
  config.virtualisation.oci-containers.containers;

  sops = {
    secrets = {
      immich-database-passsword.sopsFile = ./secrets.yaml;
    };

    templates."immich.env" = {
      restartUnits = [
        config.virtualisation.oci-containers.containers.immich-database.serviceName
      ];
      content = ''
        TZ=Etc/UTC
        IMMICH_VERSION="${IMMICH_VERSION}"
        DB_USERNAME=postgres
        DB_DATABASE_NAME=immich
        DB_PASSWORD=postgres

        POSTGRES_PASSWORD: ''${DB_PASSWORD}
        POSTGRES_USER: ''${DB_USERNAME}
        POSTGRES_DB: ''${DB_DATABASE_NAME}
        POSTGRES_INITDB_ARGS: '--data-checksums'
      '';
    };
  };
}
