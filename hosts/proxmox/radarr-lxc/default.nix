{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    radarr = {
      image = "linuxserver/radarr@sha256:620189d67078ddcfeb7a4efa424eb62f827ef734ef1e56980768bf8efd73782a";
      ports = ["8080:7878"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
        "downloads:/downloads"
        "movies:/data/movies"
        "anime:/data/anime"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
