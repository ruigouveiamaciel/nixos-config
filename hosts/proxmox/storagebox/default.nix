{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../minimal-vm ./disko.nix];

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
        ZED_EMAIL_ADDR = "ruigouveiamaciel@proton.me";
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
        ZED_EMAIL_OPTS = "@ADDRESS@";
        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;
      };
    };
    nfs.server = {
      enable = true;
      exports = "/export *(ro,fsid=0,insecure,no_subtree_check,all_squash)";
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
            "root": "/nfs"
          }
        '';
      in [
        "${filebrowserConfig}:/.filebrowser.json:ro"
        "/export:/nfs"
        "/export/services/filebrowser/database:/database"
      ];
    };
  };

  systemd.services =
    lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName rec {
        bindsTo = ["export-services-filebrowser.mount"];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
      })
    config.virtualisation.oci-containers.containers
    // {
      nfs-server = rec {
        bindsTo = [
          "export.mount"
          "export-downloads.mount"
          "export-media-movies.mount"
          "export-media-tvshows.mount"
          "export-media-anime.mount"
          "export-services-bazarr.mount"
          "export-services-filebrowser.mount"
          "export-services-immich.mount"
          "export-services-jellyfin.mount"
          "export-services-jellyseerr.mount"
          "export-services-paperless.mount"
          "export-services-prowlarr.mount"
          "export-services-qbittorrent.mount"
          "export-services-radarr.mount"
          "export-services-sonarr.mount"
          "export-services-vikunja.mount"
        ];
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

  programs.bash.shellAliases = {
    "update-config" = "cd ~/nixos-config && nix run nixpkgs#git -- pull";
    "update-fs" = "update-config && nix run nixpkgs#disko -- --root-mountpoint / --mode format --flake ~/nixos-config#proxmox-storagebox";
  };
}
