{lib, ...}: {
  options = {
    default = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          ip = lib.mkOption {
            type = lib.types.nullOr lib.types.string;
            default = null;
            description = "IP address of the service";
          };
          http = lib.mkOption {
            type = lib.types.nullOr lib.types.string;
            default = null;
            description = "HTTP address of the service";
          };
        };
      });
      default = {
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
        jellyfin = rec {
          ip = "10.0.102.4";
          http = "http://${ip}:8096";
        };
        immich = rec {
          ip = "10.0.102.4";
          http = "http://${ip}:2283";
        };
        qbittorrent = rec {
          ip = "10.0.102.5";
          http = "http://${ip}:8080";
        };
        jellyseerr = rec {
          ip = "10.0.102.16";
          http = "http://${ip}:5055";
        };
        radarr = rec {
          ip = "10.0.102.16";
          http = "http://${ip}:7878";
        };
        sonarr = rec {
          ip = "10.0.102.16";
          http = "http://${ip}:8989";
        };
        bazarr = rec {
          ip = "10.0.102.16";
          http = "http://${ip}:6767";
        };
        prowlarr = rec {
          ip = "10.0.102.16";
          http = "http://${ip}:9696";
        };
      };
    };
  };
}
