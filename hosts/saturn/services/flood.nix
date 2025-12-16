{config, ...}: {
  virtualisation.oci-containers.containers = {
    flood = {
      autoStart = true;
      image = "jesec/flood@sha256:4b92628572d0b4ff740ca2d1e0262cf8e368cd39aa9e693a6dc2f681d71aadd2";
      extraOptions = [
        "--network=podman-hostnet"
        "--ip=10.0.50.37"
      ];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/persist/services/flood:/data"
        "/persist/downloads:/downloads:ro"
      ];
    };
  };
}
