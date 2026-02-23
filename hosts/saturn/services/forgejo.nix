{config, ...}: let
  serviceName = "forgejo";
  serviceId = 1004;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "codeberg.org/forgejo/forgejo:14-rootless";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      user = "${builtins.toString config.users.users."${serviceName}".uid}:${builtins.toString config.users.groups."${serviceName}".gid}";
      extraOptions = [
        "--network=${serviceName}"
      ];
      environment = {
        USER_UID = builtins.toString config.users.users."${serviceName}".uid;
        USER_GID = builtins.toString config.users.groups."${serviceName}".gid;
      };
      ports = [
        "10.0.50.42:2015:3000/tcp"
        "10.0.50.42:2222:2222/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/data:/var/lib/gitea:U"
        "/persist/services/${serviceName}/conf:/etc/gitea:U"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };
    "${serviceName}-cloudflared" = {
      autoStart = true;
      image = "docker.io/cloudflare/cloudflared:latest";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--network=${serviceName}"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
      cmd = ["tunnel" "run"];
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
    2015
    2222
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{data,conf}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}/{data,conf}
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-cloudflared".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
  };
}
