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
      environment = {
        SEARXNG_BASE_URL = "http://10.0.50.42:8888/";
      };
      ports = [
        "10.0.50.42:8888:8080/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/etc/searxng:U"
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
    mkdir -p /persist/services/${serviceName}/config
    touch /persist/services/${serviceName}/config/settings.yml
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}
    chmod 640 /persist/services/${serviceName}/config/settings.yml
  '';

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${serviceName}/.local/share/containers";
      user = serviceName;
      group = serviceName;
      mode = "0700";
    }
  ];
}
