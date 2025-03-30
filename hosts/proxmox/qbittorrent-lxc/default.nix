{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "linuxserver/qbittorrent@sha256:50f490770308d0351e12618422e74e0613721b080f5db0bf840cf66a7281eea8";
      port = ["8080:8080"];
      environment = {
        TZ = config.time.timeZone;
        WEBUI_PORT = "8080";
        HOME = "/config";
      };
      volumes = [
        "config:/config"
        "downloads:/downloads"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
