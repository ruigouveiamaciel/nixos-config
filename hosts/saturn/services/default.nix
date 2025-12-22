{
  imports = [
    ./bazarr.nix
    ./flaresolverr.nix
    ./flood.nix
    ./gitea.nix
    ./home-assistant.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./lidarr.nix
    ./navidrome.nix
    ./paperless.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./restic.nix
    ./sonarr.nix
    ./unifi.nix
  ];

  security.apparmor.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    oci-containers.backend = "podman";
  };
}
