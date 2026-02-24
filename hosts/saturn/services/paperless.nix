{config, ...}: let
  serviceName = "paperless";
  serviceId = 1018;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://${serviceName}-broker:6379";
        PAPERLESS_OCR_LANGUAGE = "por";
        PAPERLESS_OCR_LANGUAGES = "por eng";
        PAPERLESS_CONSUMER_POLLING = "5";
        PAPERLESS_CONSUMER_POLLING_RETRY_COUNT = "60";
        PAPERLESS_CONSUMER_POLLING_DELAY = "120";
        USERMAP_UID = "${builtins.toString config.users.users."${serviceName}".uid}";
        USERMAP_GID = "${builtins.toString config.users.groups."${serviceName}".gid}";
      };
      ports = [
        "10.0.50.42:1619:8000/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/database:/usr/src/paperless/data:U"
        "/persist/services/${serviceName}/export:/usr/src/paperless/export:U"
        "/persist/services/${serviceName}/media:/usr/src/paperless/media:U"
        "/persist/services/${serviceName}/consume:/usr/src/paperless/consume"
      ];
      dependsOn = ["${serviceName}-broker"];
    };
    "${serviceName}-broker" = {
      autoStart = true;
      image = "docker.io/library/redis:8";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      volumes = [
        "/persist/services/${serviceName}/redis:/data"
      ];
    };
    "${serviceName}-importer" = {
      autoStart = true;
      image = "docker.io/garethflowers/ftp-server:latest";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      ports = [
        "10.0.50.42:2121:21/tcp"
        "10.0.50.42:2020:20/tcp"
        "10.0.50.42:40000-40009:40000-40009/tcp"
      ];
      environment = {
        PUBLIC_IP = "10.0.50.42";
        UID = "${builtins.toString config.users.users."${serviceName}".uid}";
        GID = "${builtins.toString config.users.groups."${serviceName}".gid}";
      };
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      volumes = [
        "/persist/services/${serviceName}/consume:/home/import/import"
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
  networking.firewall = {
    interfaces.enp90s0 = {
      allowedTCPPorts = [
        20
        2020
        21
        2121
        1619
      ];
      allowedTCPPortRanges = [
        {
          from = 40000;
          to = 40009;
        }
      ];
    };
    extraCommands = ''
      # Redirect port 21 to 2121
      iptables -t nat -A PREROUTING -p tcp --dport 21 -j REDIRECT --to-ports 2121
      # Redirect port 21 to 2121
      iptables -t nat -A PREROUTING -p tcp --dport 20 -j REDIRECT --to-ports 2020
    '';

    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 21 -j REDIRECT --to-ports 2121 || true
      iptables -t nat -D PREROUTING -p tcp --dport 20 -j REDIRECT --to-ports 2020 || true
    '';
  };

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{database,media,export,consume,redis}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} /persist/services/${serviceName}
    chown ${uid}:${gid} -R /persist/services/${serviceName}/{database,media,export,redis,consume}
    chown ${uid}:${gid} /persist/services/${serviceName}/secrets.env
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{database,media,export,redis,consume}

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
    "${config.virtualisation.oci-containers.containers."${serviceName}-broker".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
  };
}
