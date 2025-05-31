{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "linuxserver/sonarr@sha256:aa566541ea012f41dd0eedc8bbc67910456713b750d1ace663950ce934269036";
      ports = ["8080:8989"];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "config:/config"
        "downloads:/downloads"
        "tvshows:/data/tvshows"
        "anime:/data/anime"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
