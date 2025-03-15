{
  pkgs,
  config,
  ...
}: {
  imports = [../minimal-lxc];

  networking.hostName = "homepage";

  services.homepage-dashboard = {
    enable = true;
    package = pkgs.unstable.homepage-dashboard;
    openFirewall = true;
    listenPort = 8080;
    environmentFile = config.sops.templates."homepage.env".path;
    settings = {};
    services = [
      {
        "My First Group" = [
          {
            "My First Service" = {
              description = "Homepage is awesome";
              href = "http://localhost/";
            };
          }
        ];
      }
      {
        "My Second Group" = [
          {
            "My Second Service" = {
              description = "Homepage is the best";
              href = "http://localhost/";
            };
          }
        ];
      }
    ];
    bookmarks = [
      {
        Developer = [
          {
            Github = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
      {
        Entertainment = [
          {
            YouTube = [
              {
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
        ];
      }
    ];
  };

  sops = {
    secrets = {
      proxmox-username.sopsFile = ./secrets.yaml;
      proxmox-password.sopsFile = ./secrets.yaml;
      unifi-username.sopsFile = ./secrets.yaml;
      unifi-password.sopsFile = ./secrets.yaml;
      qbittorrent-username.sopsFile = ./secrets.yaml;
      qbittorrent-password.sopsFile = ./secrets.yaml;
      jellyfin-key.sopsFile = ./secrets.yaml;
      radarr-key.sopsFile = ./secrets.yaml;
      sonarr-key.sopsFile = ./secrets.yaml;
      bazarr-key.sopsFile = ./secrets.yaml;
      prowlarr-key.sopsFile = ./secrets.yaml;
    };

    templates."homepage.env".content = ''
      PROXMOX_USERNAME=${config.sops.placeholder.proxmox-username}
      PROXMOX_PASSWORD=${config.sops.placeholder.proxmox-password}
      UNIFI_USERNAME=${config.sops.placeholder.unifi-username}
      UNIFI_PASSWORD=${config.sops.placeholder.unifi-password}
      QBITTORRENT_USERNAME=${config.sops.placeholder.qbittorrent-username}
      QBITTORRENT_PASSWORD=${config.sops.placeholder.qbittorrent-password}
      JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
      RADARR_KEY=${config.sops.placeholder.radarr-key}
      SONARR_KEY=${config.sops.placeholder.sonarr-key}
      BAZARR=${config.sops.placeholder.bazarr-key}
      PROWLARR_KEY=${config.sops.placeholder.prowlarr-key}
    '';
  };
}
