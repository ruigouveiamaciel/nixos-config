{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation = {
    oci-containers.containers = {
      paperless-web = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:2.14.7@sha256:2a6d9f6461ad7e8335f5b2123a173b9e6002fda209af8a66483b0c00629569ab";
        extraOptions = ["--network=podman" "--network=podman-internal"];
        ports = ["8080:8000"];
        environment = {
          PAPERLESS_REDIS = "redis://paperless-broker:6379";
          PAPERLESS_OCR_LANGUAGE = "por";
          PAPERLESS_OCR_LANGUAGES = "por eng";
          PAPERLESS_CONSUMER_POLLING = "5";
          PAPERLESS_CONSUMER_POLLING_RETRY_COUNT = "60";
          PAPERLESS_CONSUMER_POLLING_DELAY = "120";
          USERMAP_UID = "${builtins.toString config.users.users.nobody.uid}";
          USERMAP_GID = "${builtins.toString config.users.groups.nogroup.gid}";
        };
        volumes = [
          "database:/usr/src/paperless/data"
          "export:/usr/src/paperless/export"
          "import:/usr/src/paperless/consume"
          "files:/usr/src/paperless/media"
        ];
        dependsOn = ["paperless-broker"];
      };
      paperless-broker = {
        image = "docker.io/library/redis:7@sha256:6aafb7f25fc93c4ff74e99cff8e85899f03901bc96e61ba12cd3c39e95503c73";
        extraOptions = ["--network=podman-internal"];
      };
    };
  };

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    anonymousUser = true;
    anonymousUploadEnable = true;
    anonymousUmask = "000";
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
    allowedTCPPorts = [21 8080];
    allowedTCPPortRanges = [
      {
        from = 49152;
        to = 65535;
      }
    ];
  };
}
