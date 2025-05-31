{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "linuxserver/qbittorrent@sha256:dc9e13d2edab18cc7c42367526182b2798f9f0f4c590559337f954fb4e3bdc35";
      ports = ["8080:8080"];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
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
