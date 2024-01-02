{config, ...}: let
  dockerEnabled = config.virtualisation.docker.enable;
in {
  virtualisation.podman = {
    enable = true;
    dockerCompat = !dockerEnabled;
    dockerSocket.enable = !dockerEnabled;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.persistence = {
    "/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/containers";
          user = "root";
          group = "root";
          mode = "0751";
        }
      ];
    };
  };
}
