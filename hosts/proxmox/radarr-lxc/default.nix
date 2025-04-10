{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    radarr = {
      image = "linuxserver/radarr@sha256:32235ce605d88a9d7dd881565286f358e657f6556b2c6ddc797c7ffbb717b432";
      ports = ["8080:7878"];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "config:/config"
        "downloads:/downloads"
        "movies:/data/movies"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
