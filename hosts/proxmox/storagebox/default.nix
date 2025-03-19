{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../minimal-vm ./disko.nix];

  boot = {
    supportedFilesystems = ["zfs"];
    kernelModules = ["zfs"];
    extraModprobeConfig = "options zfs zfs_arc_max=8589934592";
    zfs.devNodes = "/dev/disk/by-partlabel";
  };
  environment.systemPackages = with pkgs; [zfs];

  fileSystems = {
    "/export" = {
      device = "/mnt/zdata1";
      options = ["bind"];
    };
    "/export/media" = {
      device = "/mnt/zdata1/media";
      options = ["bind"];
    };
    "/export/media/personal" = {
      device = "/mnt/zdata1/media/personal";
      options = ["bind"];
    };
    "/export/downloads" = {
      device = "/mnt/zdata1/downloads";
      options = ["bind"];
    };
    "/export/services" = {
      device = "/mnt/zdata1/services";
      options = ["bind"];
    };
    "/export/services/immich/media/backups" = {
      device = "/mnt/zdata1/services/immich/media/backups";
      options = ["bind"];
    };
    "/export/services/immich/media/upload" = {
      device = "/mnt/zdata1/services/immich/media/upload";
      options = ["bind"];
    };
    "/export/services/paperless/consume" = {
      device = "/mnt/zdata1/services/paperless/consume";
      options = ["bind"];
    };
    "/export/services/paperless/media" = {
      device = "/mnt/zdata1/services/paperless/media";
      options = ["bind"];
    };
    "/export/services/paperless/export" = {
      device = "/mnt/zdata1/services/paperless/export";
      options = ["bind"];
    };
    "/export/services/vikunja/files" = {
      device = "/mnt/zdata1/services/vikunja/files";
      options = ["bind"];
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    accounts.default = {
      port = 587;
      auth = true;
      tls = true;
      host = "smtp.protonmail.ch";
      passwordeval = "cat ${config.sops.secrets.smtp-password.path}";
      user = "noreply@maciel.sh";
      from = "noreply@maciel.sh";
    };
  };

  services = {
    zfs = {
      zed.settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = "ruigouveiamaciel@proton.me";
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
        ZED_EMAIL_OPTS = "@ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
    nfs.server = {
      enable = true;
      exports = ''
        /export            10.0.102.0/24(ro,fsid=0,no_subtree_check,all_squash) 10.0.100.0/24(ro,fsid=0,no_subtree_check,all_squash)
        /export/media      10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.4(ro,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/downloads  10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.5(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/immich   10.0.102.3(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/jellyfin   10.0.102.3(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/jellyseerr   10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/radarr   10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/bazarr   10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/sonarr   10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/prowlarr   10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/vikunja   10.0.102.6(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/paperless   10.0.102.7(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services/qbittorrent   10.0.102.5(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/backups    10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
      '';
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };
  };

  sops.secrets = {
    smtp-password.sopsFile = ./secrets.yaml;
  };

  virtualisation.oci-containers.containers = {
    filebrowser = {
      image = "filebrowser/filebrowser@sha256:593478e3c24c5ea9f5d7478dc549965b7bc7030707291006ce8d0b6162d3454b";
      user = "nobody:nogroup";
      ports = ["8080:8080"];
      volumes = let
        filebrowserConfig = pkgs.writeText "filebrowserConfig.json" ''
          {
            "port": 8080,
            "baseURL": "",
            "address": "",
            "log": "stdout",
            "database": "/database/filebrowser.db",
            "root": "/srv"
          }
        '';
      in [
        "${filebrowserConfig}:/.filebrowser.json:ro"
        "/mnt/zdata1:/srv"
        "/mnt/zdata1/services/filebrowser:/database"
      ];
    };
  };

  systemd.services =
    lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName rec {
        bindsTo = ["nfs-server.service"];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      })
    config.virtualisation.oci-containers.containers
    // {
      nfs-server = rec {
        bindsTo = [
          "mnt-zdata1.mount"
          "mnt-zdata1-media.mount"
          "mnt-zdata1-media-personal.mount"
          "mnt-zdata1-downloads.mount"
          "mnt-zdata1-backups.mount"
          "mnt-zdata1-services.mount"
          "mnt-zdata1-services-immich-media-upload.mount"
          "mnt-zdata1-services-immich-media-backups.mount"
          "mnt-zdata1-services-paperless-consume.mount"
          "mnt-zdata1-services-paperless-media.mount"
          "mnt-zdata1-services-paperless-export.mount"
          "mnt-zdata1-services-vikunja-files.mount"
        ];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "on-failure";
          RestartSec = 60;
        };
      };
    };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [111 2049 4000 4001 4002 8080 20048];
      allowedUDPPorts = [111 2049 4000 4001 4002 8080 20048];
    };
    hostId = "63ded08f";
    hostName = "storagebox";
  };
}
