{
  imports = [
    ./bazarr.nix
    ./sonarr.nix
    ./radarr.nix
    ./lidarr.nix
    ./prowlarr.nix
    ./flaresolverr.nix
    ./forgejo.nix
    ./fava.nix
    ./flood.nix
    ./qbittorrent.nix
    ./seerr.nix
    ./jellyfin.nix
    ./navidrome.nix
    ./homepage.nix
  ];

  security.apparmor.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    oci-containers.backend = "podman";
  };

  boot.postBootCommands = ''
    mkdir -p /persist/media/{anime,movies,tvshows,personal,music,downloads,test}
    chown nobody:nogroup -R /persist/media
    chmod 777 -R /persist/media
  '';
}
