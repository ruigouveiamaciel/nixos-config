{
  config,
  pkgs,
  ...
}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant@sha256:97d21a71f4807d9903e1db119daebd80951ac7d5736894036638ea6ebc6f6730";
      extraOptions = ["--network=podman" "--network=podman-internal"];
      ports = ["8080:8123"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
      ];
    };
    mosquitto = {
      image = "eclipse-mosquitto@sha256:94f5a3d7deafa59fa3440d227ddad558f59d293c612138de841eec61bfa4d353";
      extraOptions = ["--network=podman" "--network=podman-internal"];
      ports = ["1883:1883"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = let
        config = pkgs.writeText "mosquitto.conf" ''
          listener 1883
          allow_anonymous true
        '';
      in [
        "${config}:/mosquitto/config/mosquitto.conf"
        "/root/mosquitto/data:/mosquitto/data"
        "/root/mosquitto/log:/mosquitto/log"
      ];
    };
    zigbee2mqtt = {
      image = "ghcr.io/koenkk/zigbee2mqtt@sha256:8a7d164906a69dab48d8f761920c9672ad889e16e27db4b912afee7903b102d7";
      extraOptions = [
        "--network=podman"
        "--network=podman-internal"
        "--device=/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_6c9223e7658cee11bd4805028acbdcd8-if00-port0"
      ];
      ports = ["8090:8080"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/root/zigbee2mqtt:/app/data"
      ];
      dependsOn = ["mosquitto"];
    };
    node-red = {
      image = "nodered/node-red:4.0@sha256:0b295b3a14c512548567ca99db631bc37b23bfc79fd009ee8248a610fafdb4b5";
      extraOptions = [
        "--network=podman"
        "--network=podman-internal"
      ];
      ports = ["8070:1880"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/root/node-red:/data"
      ];
      dependsOn = ["mosquitto"];
    };
  };

  boot.postBootCommands = ''
    mkdir -p /root/mosquitto/{data,log}
    chown -R 1883:1883 /root/mosquitto
    chmod -R 755 /root/mosquitto

    mkdir -p /root/zigbee2mqtt
    chown -R 0:0 /root/zigbee2mqtt
    chmod -R 755 /root/zigbee2mqtt

    mkdir -p /root/node-red
    chown -R 1000:0 /root/node-red
    chmod -R 775 /root/node-red
  '';

  networking.firewall.allowedTCPPorts = [1883 8070 8080 8090];
}
