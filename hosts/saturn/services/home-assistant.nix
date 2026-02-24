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
      image = "ghcr.io/home-assistant/home-assistant:2026.2";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      ports = [
        "10.0.50.42:8123:8123/tcp"
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
      image = "ghcr.io/koenkk/zigbee2mqtt:2.8";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
        "--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_6c9223e7658cee11bd4805028acbdcd8-if00-port0"
      ];
      ports = [
        "10.0.50.42:8124:8080/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/zigbee2mqtt:/app/data:U"
      ];
      dependsOn = ["${serviceName}-mosquitto"];
    };
    "${serviceName}-node-red" = {
      autoStart = true;
      image = "docker.io/nodered/node-red:4.1";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--network=${serviceName}"
      ];
      ports = [
        "10.0.50.42:8125:1880/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/node-red:/data:U"
      ];
      dependsOn = ["${serviceName}-mosquitto"];
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
    8123
    8124
    8125
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/{config,zigbee2mqtt,node-red}
    mkdir -p /persist/services/${serviceName}/mosquitto/{data,log}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}/{config,zigbee2mqtt,node-red,mosquitto}
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
    "${config.virtualisation.oci-containers.containers."${serviceName}-mosquitto".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-zigbee2mqtt".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-node-red".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
    "${config.virtualisation.oci-containers.containers."${serviceName}-cloudflared".serviceName}" = {
      requires = ["${serviceName}-network.service"];
      after = ["${serviceName}-network.service"];
    };
  };
}
