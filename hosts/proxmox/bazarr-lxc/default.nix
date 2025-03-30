{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    bazarr = {
      image = "linuxserver/bazarr@sha256:36f4ba69ab5bfb32c384ea84cf0036b8b6e07fb9a7ab65885f3619de2a8318f8";
      ports = ["8080:6767"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "config:/config"
        "tvshows:/data/tvshows"
        "anime:/data/anime"
        "movies:/data/movies"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
