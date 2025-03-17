{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../minimal-vm];

  networking.hostName = "paperless";

  services.rpcbind.enable = true;
  fileSystems = {
    "/mnt/config" = {
      device = "10.0.102.3:/services/paperless";
      fsType = "nfs";
      options = ["nfsvers=4.2"];
    };
    "/var/www/anonymous" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "size=16M" "mode=755" "uid=65534" "gid=65534"];
    };
    "/var/www/anonymous/consume" = {
      device = "10.0.102.3:/services/paperless/consume";
      fsType = "nfs";
      options = ["nfsvers=4.2"];
      depends = ["/var/www/anonymous"];
    };
  };

  virtualisation.oci-containers.containers = {
    paperless-web = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.14.7@sha256:2a6d9f6461ad7e8335f5b2123a173b9e6002fda209af8a66483b0c00629569ab";
      extraOptions = ["--network=podman" "--network=paperless"];
      ports = ["8000:8000"];
      environment = {
        PAPERLESS_REDIS = "redis://paperless-broker:6379";
        PAPERLESS_OCR_LANGUAGE = "por";
        PAPERLESS_OCR_LANGUAGES = "por eng";
        PAPERLESS_CONSUMER_POLLING = "5";
        PAPERLESS_CONSUMER_POLLING_RETRY_COUNT = "60";
        PAPERLESS_CONSUMER_POLLING_DELAY = "120";
        USERMAP_UID = "65534"; # nobody
        USERMAP_GID = "65534"; # nogroup
      };
      volumes = [
        "/mnt/config/data:/usr/src/paperless/data"
        "/mnt/config/export:/usr/src/paperless/export"
        "/mnt/config/consume:/usr/src/paperless/consume"
        "/mnt/config/media:/usr/src/paperless/media"
      ];
      dependsOn = ["paperless-broker"];
    };
    paperless-broker = {
      image = "docker.io/library/redis:7@sha256:6aafb7f25fc93c4ff74e99cff8e85899f03901bc96e61ba12cd3c39e95503c73";
      extraOptions = [
        "--network=paperless"
        "--health-cmd"
        "redis-cli ping || exit 1"
      ];
    };
  };

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    anonymousUser = true;
    anonymousUploadEnable = true;
    anonymousUmask = "022";
    anonymousMkdirEnable = false;
    anonymousUserHome = "/var/www/anonymous";
    anonymousUserNoPassword = true;
    extraConfig = ''
      pasv_enable=YES
      pasv_min_port=49152
      pasv_max_port=65535
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [21 8000];
    allowedTCPPortRanges = [
      {
        from = 49152;
        to = 65535;
      }
    ];
  };

  systemd.services = let
    inherit (config.virtualisation.oci-containers) backend;
  in
    lib.attrsets.mapAttrs' (serviceName: _:
      lib.attrsets.nameValuePair "${backend}-${serviceName}" rec {
        bindsTo = ["mnt-config.mount" "create-paperless-network.service"];
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
      create-paperless-network = {
        after = ["podman.service"];
        script = ''
          ${pkgs.podman}/bin/podman network exists paperless || \
          ${pkgs.podman}/bin/podman network create --internal paperless
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      vsftpd = rec {
        bindsTo = ["var-www-anonymous.mount" "var-www-anonymous-consume.mount"];
        after = bindsTo;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
        startLimitBurst = 60;
        startLimitIntervalSec = 3600;
      };
    };
}
