{config, ...}: {
  virtualisation.oci-containers.containers = {
    bazarr = {
      image = "linuxserver/bazarr@sha256:9cea5b5c817379690bb5c53cd14bbf21fec44d39870d56a1d9e003f27a642509";
      ports = ["6767:6767"];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "/persist/services/bazarr/config:/config"
        "/persist/media/tvshows:/data/tvshows"
        "/persist/media/anime:/data/anime"
        "/persist/media/movies:/data/movies"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [6767];
}
