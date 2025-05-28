{lib, ...}: {
  # TODO: Move this into myConstants
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
      default = {
        devbox = rec {
          ip = "10.0.102.2";
          http = "http://${ip}:8080";
        };
        vikunja = rec {
          ip = "10.0.102.11";
          http = "http://${ip}:8080";
        };
        paperless = rec {
          ip = "10.0.102.10";
          http = "http://${ip}:8080";
        };
        jellyfin = rec {
          ip = "10.0.102.12";
          http = "http://${ip}:8080";
        };
        immich = rec {
          ip = "10.0.102.13";
          http = "http://${ip}:8080";
        };
        qbittorrent = rec {
          ip = "10.0.102.3";
          http = "http://${ip}:8080";
        };
        flood = rec {
          ip = "10.0.102.4";
          http = "http://${ip}:8080";
        };
        jellyseerr = rec {
          ip = "10.0.102.9";
          http = "http://${ip}:8080";
        };
        radarr = rec {
          ip = "10.0.102.5";
          http = "http://${ip}:8080";
        };
        sonarr = rec {
          ip = "10.0.102.6";
          http = "http://${ip}:8080";
        };
        bazarr = rec {
          ip = "10.0.102.7";
          http = "http://${ip}:8080";
        };
        prowlarr = rec {
          ip = "10.0.102.8";
          http = "http://${ip}:8080";
        };
        homepage = rec {
          ip = "10.0.102.254";
          http = "http://${ip}:8080";
        };
        unifi = rec {
          ip = "10.0.102.253";
          http = "https://${ip}:8443";
        };
        pfSense = rec {
          ip = "10.0.0.1";
          http = "https://${ip}";
        };
        proxmox = rec {
          ip = "10.0.0.2";
          http = "https://${ip}:8006";
        };
      };
    };
  };
}
