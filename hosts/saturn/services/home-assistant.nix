{
  config,
  pkgs,
  ...
}: let
  serviceName = "home-assistant";
  serviceId = 1005;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:2026.6";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=host"
      ];
      volumes = [
        "/persist/services/${serviceName}/config:/config:U"
      ];
    };
    "${serviceName}-mosquitto" = {
      autoStart = true;
      image = "docker.io/eclipse-mosquitto:2";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      ports = [
        "127.0.0.1:1883:1883/tcp"
      ];
      volumes = let
        config = pkgs.writeText "mosquitto.conf" ''
          listener 1883
          allow_anonymous true
        '';
      in [
        "${config}:/mosquitto/config/mosquitto.conf:ro"
        "/persist/services/${serviceName}/mosquitto/data:/mosquitto/data:U"
        "/persist/services/${serviceName}/mosquitto/log:/mosquitto/log:U"
      ];
    };
    "${serviceName}-zigbee2mqtt" = {
      autoStart = true;
      image = "ghcr.io/koenkk/zigbee2mqtt:2.11";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--group-add"
        "keep-groups"
        "--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_6c9223e7658cee11bd4805028acbdcd8-if00-port0:/dev/ttyACM0"
      ];
      ports = [
        "10.0.50.42:8124:8080/tcp"
      ];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/persist/services/${serviceName}/zigbee2mqtt:/app/data:U"
        "/run/udev:/run/udev:ro"
      ];
      dependsOn = ["${serviceName}-mosquitto"];
    };
    "${serviceName}-music-assistant" = {
      autoStart = true;
      image = "ghcr.io/music-assistant/server:2.8";
      pull = "newer";
      extraOptions = [
        "--network=${serviceName}_macvlan"
        "--ip"
        "10.0.50.95"
        "--sysctl"
        "net.ipv6.conf.all.disable_ipv6=1"
        "--sysctl"
        "net.ipv6.conf.default.disable_ipv6=1"
        "--sysctl"
        "net.ipv6.conf.lo.disable_ipv6=1"
      ];
      environment = {
        LOG_LEVEL = "info";
      };
      volumes = [
        "/persist/services/${serviceName}/music-assistant:/data:U"
        "/persist/forced/media/music:/media:ro"
      ];
    };
  };

  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package pkgs.passt];
    uid = serviceId;
    group = serviceName;
    extraGroups = ["dialout"];
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
  networking.firewall.interfaces.enp90s0 = {
    allowedUDPPorts = [
      5353
    ];
    allowedTCPPorts = [
      8123
      8124
      8125
      21064
    ];
  };

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /var/lib/${serviceName}
    chown ${uid}:${gid} /var/lib/${serviceName}
    chmod 750 /var/lib/${serviceName}
    mkdir -p /persist/services/${serviceName}/{config,zigbee2mqtt,music-assistant}
    mkdir -p /persist/services/${serviceName}/mosquitto/{data,log}
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{config,zigbee2mqtt,node-red,mosquitto}
  '';

  systemd.services = {
    "${serviceName}-network-root" = {
      requires = ["user-runtime-dir@${builtins.toString config.users.users.root.uid}.service"];
      after = ["user-runtime-dir@${builtins.toString config.users.users.root.uid}.service"];
      script = let
        podman = "${config.virtualisation.podman.package}/bin/podman";
      in ''
        ${podman} network exists ${serviceName} || \
        ${podman} network create \
          -d macvlan \
          --subnet=10.0.50.0/24 \
          --gateway=10.0.50.1 \
          -o parent=enp90s0 \
          ${serviceName}_macvlan
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}".serviceName}" = {
      requires = ["${serviceName}-network-root.service"];
      after = ["${serviceName}-network-root.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-music-assistant".serviceName}" = {
      requires = ["${serviceName}-network-root.service"];
      after = ["${serviceName}-network-root.service"];
    };
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-mosquitto".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-zigbee2mqtt".serviceName}" = {
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
