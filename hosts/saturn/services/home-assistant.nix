{
  config,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers = {
    home-assistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant@sha256:75ef6851d2e48d366764cdb6b569b7ad8be77dcc8e0d1b9aa508ac90e42d4c58";
      podman = {
        sdnotify = "healthy";
        user = "homeassistant";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:8123 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "8123:8123/tcp"
      ];
      volumes = [
        "/persist/services/home-assistant/config:/config"
      ];
    };
    mosquitto = {
      autoStart = true;
      image = "docker.io/eclipse-mosquitto@sha256:3c1ac53c1438f1f54721d83dad04b02c9c9e2d164126e10ce4d09ccd968a6324";
      podman = {
        sdnotify = "healthy";
        user = "homeassistant";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "mosquitto_sub -h localhost -p 1883 -t '$SYS/broker/uptime' -C 1 -W 5 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "1883:1883/tcp"
      ];
      volumes = let
        config = pkgs.writeText "mosquitto.conf" ''
          listener 1883
          allow_anonymous true
        '';
      in [
        "${config}:/mosquitto/config/mosquitto.conf:ro"
        "/persist/services/home-assistant/mosquitto/data:/mosquitto/data"
        "/persist/services/home-assistant/mosquitto/log:/mosquitto/log"
      ];
    };
    zigbee2mqtt = {
      autoStart = true;
      image = "ghcr.io/koenkk/zigbee2mqtt@sha256:163e7351430a95d550d5b1bb958527edc1eff115eb013ca627f3545a192e853f";
      podman = {
        sdnotify = "healthy";
        user = "homeassistant";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:8080 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
        # TODO: Add Zigbee Coordinator device
        # "--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_6c9223e7658cee11bd4805028acbdcd8-if00-port0"
      ];
      ports = [
        "8124:8080/tcp"
      ];
      volumes = [
        "/persist/services/home-assistant/zigbee2mqtt:/app/data"
      ];
      dependsOn = ["mosquitto"];
    };
    node-red = {
      autoStart = true;
      image = "docker.io/nodered/node-red@sha256:cfddc4abad871a7b7e420ba7919c6e12bb05112cb693bf10729e0d8f6f404102";
      podman = {
        sdnotify = "healthy";
        user = "homeassistant";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:1880 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      ports = [
        "8125:1880/tcp"
      ];
      volumes = [
        "/persist/services/home-assistant/node-red:/data"
      ];
      dependsOn = ["mosquitto"];
    };
  };

  users.users.homeassistant = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1005;
    group = "homeassistant";
  };

  users.groups.homeassistant = {
    gid = 1005;
  };

  networking.firewall.allowedTCPPorts = [
    8123
    8124
    8125
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/home-assistant/{config,zigbee2mqtt,node-red}
    mkdir -p /persist/services/home-assistant/mosquitto/{data,log}
    chown -R ${builtins.toString config.users.users.homeassistant.uid}:${builtins.toString config.users.groups.homeassistant.gid} /persist/services/home-assistant
    chmod -R 750 /persist/services/home-assistant
  '';
}
