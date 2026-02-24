{config, ...}: let
  serviceName = "immich";
  serviceId = 1016;
  version = "v2";
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      hostname = "immich";
      autoStart = true;
      image = "ghcr.io/immich-app/immich-server:${version}";
      pull = "newer";
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--no-healthcheck"
        "--device=/dev/dri:/dev/dri"
      ];
      ports = [
        "10.0.50.42:2283:2283/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/upload:/data:U"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      environment = {
        IMMICH_VERSION = version;
        TZ = config.time.timeZone;
      };
      dependsOn = [
        "${serviceName}-redis"
        "${serviceName}-database"
      ];
    };
    "${serviceName}-machine-learning" = {
      hostname = "immich-machine-learning";
      autoStart = true;
      image = "ghcr.io/immich-app/immich-machine-learning:${version}-openvino";
      pull = "newer";
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--no-healthcheck"
        "--device=/dev/dri:/dev/dri"
      ];
      volumes = [
        "/persist/services/${serviceName}/cache:/cache:U"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      environment = {
        IMMICH_VERSION = version;
        TZ = config.time.timeZone;
      };
    };
    "${serviceName}-redis" = {
      hostname = "redis";
      autoStart = true;
      image = "docker.io/valkey/valkey:9@sha256:546304417feac0874c3dd576e0952c6bb8f06bb4093ea0c9ca303c73cf458f63";
      pull = "newer";
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      capabilities = {
        CAP_DAC_OVERRIDE = true;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--health-cmd"
        "redis-cli ping || exit 1"
      ];
      volumes = [
        "/persist/services/${serviceName}/redis:/data:U"
      ];
    };
    "${serviceName}-database" = {
      hostname = "database";
      autoStart = true;
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      pull = "newer";
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--no-healthcheck"
        "--shm-size"
        "128mb"
      ];
      volumes = [
        "/persist/services/${serviceName}/database:/var/lib/postgresql/data:U"
      ];
      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      dependsOn = [
        "${serviceName}-redis"
        "${serviceName}-database"
      ];
    };
  };

  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = serviceId;
    group = serviceName;
    home = "/var/lib/${serviceName}";
    createHome = true;
    subUidRanges = [
      {
        count = 65536;
        startUid = serviceId * 100000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = serviceId * 100000;
      }
    ];
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    2283
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{upload,cache,database,redis}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{upload,cache,database,redis}
    chmod 600 /persist/services/${serviceName}/secrets.env
  '';

  systemd.services = {
    "${serviceName}-network" = {
      wantedBy = ["multi-user.target"];
      script = let
        podman = "${config.virtualisation.podman.package}/bin/podman";
      in ''
        ${podman} network exists ${serviceName} || \
        ${podman} network create ${serviceName}
      '';
      serviceConfig = {
        Type = "oneshot";
        User = serviceName;
        RemainAfterExit = true;
      };
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-machine-learning".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-redis".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-database".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
  };
}
