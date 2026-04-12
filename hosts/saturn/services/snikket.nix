{config, ...}: let
  serviceName = "snikket";
  serviceId = 1019;
in {
  # Before first boot, populate secrets.env:
  #   SNIKKET_DOMAIN=chat.example.com
  #   SNIKKET_ADMIN_EMAIL=you@example.com
  virtualisation.oci-containers.containers = {
    "${serviceName}-server" = {
      autoStart = true;
      image = "snikket/snikket-server:stable";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = ["--network=${serviceName}"];
      ports = [
        "10.0.50.69:5222:5222/tcp"
        "10.0.50.69:5269:5269/tcp"
        "10.0.50.69:5000:5000/tcp"
        "10.0.50.69:3478:3478/tcp"
        "10.0.50.69:3478:3478/udp"
        "10.0.50.69:5349:5349/tcp"
        "10.0.50.69:5349:5349/udp"
      ];
      environmentFiles = ["/persist/services/${serviceName}/secrets.env"];
      volumes = [
        "/persist/services/${serviceName}/data:/snikket:U"
      ];
    };
    "${serviceName}-proxy" = {
      autoStart = true;
      image = "snikket/snikket-web-proxy:stable";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = ["--network=${serviceName}"];
      ports = [
        "10.0.50.69:80:80/tcp"
        "10.0.50.69:443:443/tcp"
      ];
      environmentFiles = ["/persist/services/${serviceName}/secrets.env"];
      volumes = [
        "/persist/services/${serviceName}/data:/snikket:U"
        "/persist/services/${serviceName}/acme-challenges:/var/www/html/.well-known/acme-challenge:U"
      ];
    };
    "${serviceName}-certs" = {
      autoStart = true;
      image = "snikket/snikket-cert-manager:stable";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = ["--network=${serviceName}"];
      environmentFiles = ["/persist/services/${serviceName}/secrets.env"];
      volumes = [
        "/persist/services/${serviceName}/data:/snikket:U"
        "/persist/services/${serviceName}/acme-challenges:/var/www/.well-known/acme-challenge:U"
      ];
    };
    "${serviceName}-portal" = {
      autoStart = true;
      image = "snikket/snikket-web-portal:stable";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = ["--network=${serviceName}"];
      environmentFiles = ["/persist/services/${serviceName}/secrets.env"];
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

  # Dedicated IP for Snikket on the LAN — merged with existing addresses in default.nix
  networking.interfaces.enp90s0.ipv4.addresses = [
    {
      address = "10.0.50.69";
      prefixLength = 24;
    }
  ];

  # Rootless Podman needs this to bind port mappings < 1024 on the host side
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  networking.firewall.interfaces.enp90s0 = {
    allowedTCPPorts = [
      80 # HTTP / ACME challenges
      443 # HTTPS / web portal
      5222 # XMPP client-to-server
      5269 # XMPP server-to-server (federation)
      5000 # proxy65 file transfer
      5349 # STUN/TURN over TLS
    ];
    allowedUDPPorts = [
      3478 # STUN/TURN
      5349 # STUN/TURN over TLS
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 65535; # TURN media relay
      }
    ];
  };

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{data,acme-challenges}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{data,acme-challenges}
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-server".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-proxy".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-certs".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-portal".serviceName}" = {
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
