{lib, ...}: {
  options = {
    default = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          ip = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "IP address of the service";
          };
          http = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "HTTP address of the service";
          };
        };
      });
      default = rec {
        devbox = {
          ip = "10.0.102.2";
        };
        nfs = rec {
          ip = "10.0.102.3";
          http = "http://${ip}:8080";
        };
        vikunja = rec {
          ip = "10.0.102.6";
          http = "http://${ip}:3456";
        };
        paperless = rec {
          ip = "10.0.102.7";
          http = "http://${ip}:8000";
        };
        media-server = {
          ip = "10.0.102.4";
        };
        jellyfin = rec {
          inherit (media-server) ip;
          http = "http://${ip}:8096";
        };
        immich = rec {
          inherit (media-server) ip;
          http = "http://${ip}:2283";
        };
        qbittorrent = rec {
          ip = "10.0.102.5";
          http = "http://${ip}:8080";
        };
        media-management = {
          ip = "10.0.102.16";
        };
        jellyseerr = rec {
          inherit (media-management) ip;
          http = "http://${ip}:5055";
        };
        radarr = rec {
          inherit (media-management) ip;
          http = "http://${ip}:7878";
        };
        sonarr = rec {
          inherit (media-management) ip;
          http = "http://${ip}:8989";
        };
        bazarr = rec {
          inherit (media-management) ip;
          http = "http://${ip}:6767";
        };
        prowlarr = rec {
          inherit (media-management) ip;
          http = "http://${ip}:9696";
        };
      };
    };
  };
}
