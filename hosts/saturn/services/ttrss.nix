{config, ...}: let
  serviceName = "ttrss";
  serviceId = 1021;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}-app" = {
      hostname = "app";
      autoStart = true;
      image = "ghcr.io/tt-rss/tt-rss:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--group-add"
        "keep-groups"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      environment = {
        OWNER_UID = builtins.toString config.users.users."${serviceName}".uid;
        OWNER_GID = builtins.toString config.users.groups."${serviceName}".gid;
      };
      volumes = [
        "/persist/services/${serviceName}/app:/var/www/html"
        "/persist/services/${serviceName}/config.d:/opt/tt-rss/config.d:ro"
      ];
      dependsOn = [
        "${serviceName}-db"
      ];
    };
    "${serviceName}-db" = {
      hostname = "db";
      autoStart = true;
      image = "postgres:17-alpine";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      volumes = [
        "/persist/services/${serviceName}/postgres:/var/lib/postgresql/data:U"
      ];
    };
    "${serviceName}-updater" = {
      hostname = "updater";
      autoStart = true;
      image = "ghcr.io/tt-rss/tt-rss:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--group-add"
        "keep-groups"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      environment = {
        OWNER_UID = builtins.toString config.users.users."${serviceName}".uid;
        OWNER_GID = builtins.toString config.users.groups."${serviceName}".gid;
      };
      volumes = [
        "/persist/services/${serviceName}/app:/var/www/html"
        "/persist/services/${serviceName}/config.d:/opt/tt-rss/config.d:ro"
      ];
      dependsOn = [
        "${serviceName}-app"
      ];
      cmd = ["/opt/tt-rss/updater.sh"];
    };
    "${serviceName}-web" = {
      hostname = "web-nginx";
      autoStart = true;
      image = "ghcr.io/tt-rss/tt-rss-web-nginx:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--group-add"
        "keep-groups"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      environment = {
        OWNER_UID = builtins.toString config.users.users."${serviceName}".uid;
        OWNER_GID = builtins.toString config.users.groups."${serviceName}".gid;
        RESOLVER = "10.89.0.1";
      };
      volumes = [
        "/persist/services/${serviceName}/app:/var/www/html:ro"
      ];
      dependsOn = [
        "${serviceName}-app"
      ];
      ports = [
        "8280:80/tcp"
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
    8280
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /var/lib/${serviceName}
    chown ${uid}:${gid} /var/lib/${serviceName}
    chmod 750 /var/lib/${serviceName}
    mkdir -p /persist/services/${serviceName}/{postgres,app,config.d}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{postgres,config.d}
    chmod 755 -R /persist/services/${serviceName}/app
    chmod 600 /persist/services/${serviceName}/secrets.env
  '';

  systemd.services = {
    "${serviceName}-network" = {
      requires = ["user-runtime-dir@${builtins.toString config.users.users."${serviceName}".uid}.service"];
      after = ["user-runtime-dir@${builtins.toString config.users.users."${serviceName}".uid}.service"];
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-db".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-web".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-app".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-updater".serviceName}" = {
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
