{config, ...}: {
  virtualisation.oci-containers.containers = {
    homepage = {
      autoStart = true;
      image = "ghcr.io/gethomepage/homepage@sha256:7dc099d5c6ec7fc945d858218565925b01ff8a60bcbfda990fc680a8b5cd0b6e";
      podman = {
        sdnotify = "healthy";
        user = "homepage";
      };
      capabilities = {
        CAP_SETUID = true;
        CAP_SETGID = true;
        CAP_CHOWN = true;
        CAP_FOWNER = true;
        CAP_DAC_OVERRIDE = true;
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--userns=keep-id"
        "--health-cmd"
        "curl -f http://localhost:3000 || exit 1"
        "--health-interval"
        "30s"
        "--health-retries"
        "3"
      ];
      environment = {
        PUID = builtins.toString config.users.users.homepage.uid;
        PGID = builtins.toString config.users.groups.homepage.gid;
        HOMEPAGE_ALLOWED_HOSTS = "10.0.0.42:8080";
        PORT = "3000";
      };
      ports = [
        "8080:3000/tcp"
      ];
      volumes = [
        "/persist/services/homepage:/app/config"
      ];
    };
  };

  users.users.homepage = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = 1006;
    group = "homepage";
  };

  users.groups.homepage = {
    gid = 1006;
  };

  networking.firewall.allowedTCPPorts = [
    8080
  ];

  boot.postBootCommands = ''
    mkdir -p /persist/services/homepage
    chown -R ${builtins.toString config.users.users.homepage.uid}:${builtins.toString config.users.groups.homepage.gid} /persist/services/homepage
    chmod -R 750 /persist/services/homepage
  '';

  sops = {
    secrets = {
      jellyfin-key.sopsFile = ../secrets.yaml;
      jellyseerr-key.sopsFile = ../secrets.yaml;
      prowlarr-key.sopsFile = ../secrets.yaml;
      bazarr-key.sopsFile = ../secrets.yaml;
      sonarr-key.sopsFile = ../secrets.yaml;
      radarr-key.sopsFile = ../secrets.yaml;
      openwrt-username.sopsFile = ../secrets.yaml;
      openwrt-password.sopsFile = ../secrets.yaml;
      unifi-username.sopsFile = ../secrets.yaml;
      unifi-password.sopsFile = ../secrets.yaml;
      flood-username.sopsFile = ../secrets.yaml;
      flood-password.sopsFile = ../secrets.yaml;
      immich-key.sopsFile = ../secrets.yaml;
      paperless-key.sopsFile = ../secrets.yaml;
    };

    templates."homepage.env" = {
      restartUnits = ["homepage-dashboard.service"];
      inherit (config.users.users.homepage) uid;
      inherit (config.users.groups.homepage) gid;
      mode = "400";
      content = ''
        HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
        HOMEPAGE_VAR_UNIFI_USERNAME=${config.sops.placeholder.unifi-username}
        HOMEPAGE_VAR_UNIFI_PASSWORD=${config.sops.placeholder.unifi-password}
        HOMEPAGE_VAR_FLOOD_USERNAME=${config.sops.placeholder.flood-username}
        HOMEPAGE_VAR_FLOOD_PASSWORD=${config.sops.placeholder.flood-password}
        HOMEPAGE_VAR_OPENWRT_USERNAME=${config.sops.placeholder.openwrt-username}
        HOMEPAGE_VAR_OPENWRT_PASSWORD=${config.sops.placeholder.openwrt-password}
        HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
        HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder.radarr-key}
        HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder.sonarr-key}
        HOMEPAGE_VAR_BAZARR_KEY=${config.sops.placeholder.bazarr-key}
        HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder.prowlarr-key}
        HOMEPAGE_VAR_JELLYSEERR_KEY=${config.sops.placeholder.jellyseerr-key}
        HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder.immich-key}
        HOMEPAGE_VAR_PAPERLESS_KEY=${config.sops.placeholder.paperless-key}
      '';
    };
  };
}
