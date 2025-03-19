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
  };
  environment.systemPackages = with pkgs; [zfs];

  fileSystems = {
    "/export/media" = {
      device = "/mnt/das/media";
      options = ["bind"];
    };
    "/export/torrenting" = {
      device = "/mnt/das/torrenting";
      options = ["bind"];
    };
    "/export/services" = {
      device = "/mnt/das/services";
      options = ["bind"];
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    accounts.default = {
      port = 587;
      auth = "on";
      tls = "on";
      host = "smtp.protonmail.ch";
      passwordeval = "cat ${config.sops.secrets.smtp-password.path}";
      user = "ruigouveiamaciel@proton.me";
      from = "noreply@maciel.sh";
    };
  };

  services = {
    zfs = {
      zed.settings = {};
    };
    nfs.server = {
      enable = true;
      exports = ''
        /export         10.0.102.0/24(ro,fsid=0,no_subtree_check,all_squash) 10.0.100.0/24(ro,fsid=0,no_subtree_check,all_squash)
        /export/torrenting  10.0.102.0/24(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/services  10.0.102.0/24(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
        /export/documents  10.0.102.0/24(rw,nohide,insecure,no_subtree_check,all_squash) 10.0.100.0/24(rw,nohide,insecure,no_subtree_check)
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
        "/mnt/das:/srv"
        "/mnt/das/.filebrowser:/database"
      ];
    };
  };

  systemd.services =
    lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName rec {
        bindsTo = ["mnt-zdata1.mount"];
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
        bindsTo = ["mnt-zdata1.mount"];
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
