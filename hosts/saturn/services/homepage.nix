{config, ...}: let
  serviceName = "homepage";
  serviceId = 1006;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "ghcr.io/gethomepage/homepage:v1";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      environment = {
        PUID = builtins.toString config.users.users."${serviceName}".uid;
        PGID = builtins.toString config.users.groups."${serviceName}".gid;
        HOMEPAGE_ALLOWED_HOSTS = "10.0.50.42:8080";
        PORT = "8080";
      };
      ports = [
        "10.0.50.42:8080:8080/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/app/config"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
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
    8080
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/config
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/config
    chmod 600 /persist/services/${serviceName}/secrets.env
  '';

  environment.persistence."/persist".directories = [
    {directory = "/var/lib/${serviceName}/.local/share/containers/storage"; user = serviceName; group = serviceName; mode = "0700";}
  ];
}
