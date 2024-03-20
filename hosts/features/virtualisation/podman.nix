{
  pkgs,
  config,
  ...
}: let
  dockerEnabled = config.virtualisation.docker.enable;
in {
  virtualisation.podman = {
    enable = true;
    package = pkgs.podman;
    dockerCompat = !dockerEnabled;
    dockerSocket.enable = !dockerEnabled;
    defaultNetwork.settings.dns_enabled = true;
  };
}
