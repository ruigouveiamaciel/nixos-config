{config, ...}: let
  IMMICH_VERSION = "v1.130.3";
in {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:${IMMICH_VERSION}";
      extraOptions = [
        "--network=podman-internal"
        "--network=podman"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--no-healthcheck"
      ];
      environmentFiles = [config.sops.templates."immich.env".path];
      ports = ["8080:2283"];
      volumes = [
        "files:/usr/src/app/upload"
      ];
      dependsOn = [
        "immich-redis"
        "immich-database"
      ];
    };
    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION}-openvino";
      extraOptions = [
        "--network=podman-internal"
        "--network=podman"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--no-healthcheck"
      ];
      environmentFiles = [config.sops.templates."immich.env".path];
    };
    immich-redis = {
      hostname = "redis";
      image = "docker.io/redis:6.2-alpine@sha256:148bb5411c184abd288d9aaed139c98123eeb8824c5d3fce03cf721db58066d8";
      extraOptions = [
        "--network=podman-internal"
        "--health-cmd"
        "redis-cli ping || exit 1"
      ];
    };
    immich-database = {
      hostname = "database";
      image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:739cdd626151ff1f796dc95a6591b55a714f341c737e27f045019ceabf8e8c52";
      user = "nobody:nogroup";
      extraOptions = [
        "--network=podman-internal"
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
        "database:/var/lib/postgresql/data"
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

  networking.firewall.allowedTCPPorts = [8080];

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
        TZ=${config.time.timeZone}
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
