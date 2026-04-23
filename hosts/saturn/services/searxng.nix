{config, ...}: let
  serviceName = "searxng";
  serviceId = 1020;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "docker.io/searxng/searxng:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      environment = {
        SEARXNG_BASE_URL = "http://10.0.50.42:8888/";
      };
      ports = [
        "10.0.50.42:8888:8080/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/etc/searxng:U"
        "/persist/services/${serviceName}/data:/var/cache/searxng:U"
      ];
      dependsOn = ["${serviceName}-valkey"];
    };
    "${serviceName}-valkey" = {
      autoStart = true;
      image = "docker.io/valkey/valkey:9-alpine";
      pull = "newer";
      cmd = ["valkey-server" "--save" "30" "1" "--loglevel" "warning"];
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      volumes = [
        "/persist/services/${serviceName}/valkey:/data"
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
    8888
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{config,data,valkey}
    touch /persist/services/${serviceName}/config/settings.yml
    chown ${uid}:${gid} /persist/services/${serviceName}
    chown ${uid}:${gid} -R /persist/services/${serviceName}/{config,data,valkey}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{config,data,valkey}
    chmod 640 /persist/services/${serviceName}/config/settings.yml
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-valkey".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${serviceName}/.local/share/containers";
      user = serviceName;
      group = serviceName;
      mode = "0700";
    }
  ];
}
