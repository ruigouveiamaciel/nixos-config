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
        /export                                10.0.102.0/24(ro,fsid=0,no_subtree_check,all_squash)

        /export/media                          10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.4(ro,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/media/personal                 10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.4(ro,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/downloads                      10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.5(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/backups                        10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/services                       10.0.102.0/24(ro,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,insecure,no_subtree_check,all_squash)

        /export/services/immich                10.0.102.4(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/immich/media/upload   10.0.102.4(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/immich/media/backups  10.0.102.4(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/jellyfin              10.0.102.4(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/services/jellyseerr            10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/radarr                10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/bazarr                10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/sonarr                10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/prowlarr              10.0.102.16(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/services/vikunja               10.0.102.6(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/vikunja/files         10.0.102.6(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/services/paperless             10.0.102.7(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/paperless/consume     10.0.102.7(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/paperless/media       10.0.102.7(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
        /export/services/paperless/export      10.0.102.7(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)

        /export/services/qbittorrent           10.0.102.5(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.102.2(rw,nohide,insecure,no_subtree_check,all_squash)
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
        "/export:/srv"
        "/export/services/filebrowser:/database"
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
        bindsTo = ["zfs-import-zdata1.service"];
        after = bindsTo;
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
