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
    mkdir -p /persist/media/{anime,movies,tvshows,personal,music,downloads}
    chown nobody:nogroup -R /persist/media
    chmod 777 -R /persist/media
  '';
}
