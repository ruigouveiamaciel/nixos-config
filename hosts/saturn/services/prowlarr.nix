{config, ...}: {
  virtualisation.oci-containers.containers = {
    prowlarr = {
      autoStart = true;
      image = "linuxserver/prowlarr@sha256:aeb303a86be70dfb3fa5508bbd9399f5123b74f73b00b91eb76eb34efe4c5650";
      podman.sdnotify = "healthy";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.96"
        "--health-cmd"
        "curl -f http://localhost:9696 || exit 1"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = builtins.toString config.users.users.nobody.uid;
        PGID = builtins.toString config.users.groups.nogroup.gid;
      };
      volumes = [
        "/persist/services/prowlarr:/config"
      ];
    };
  };
}
