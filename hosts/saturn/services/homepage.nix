{
  config,
  pkgs,
  ...
}: let
  serviceName = "homepage";
  serviceId = 1006;

  settingsYaml = pkgs.writeText "settings.yaml" ''
    title: Saturn
    theme: dark
    color: slate
    headerStyle: clean
    hideVersion: true
    layout:
      Media:
      Media Automation:
      Downloads:
      Productivity:
      Network:
  '';

  servicesYaml = pkgs.writeText "services.yaml" ''
    - Media:
        - Jellyfin:
            href: http://10.0.50.42:8096
            description: Media streaming server
            icon: jellyfin.png
        - Immich:
            href: http://10.0.50.42:2283
            description: Photos and videos backup
            icon: immich.png
        - Navidrome:
            href: http://10.0.50.42:4533
            description: Music streaming server
            icon: navidrome.png
        - Seerr:
            href: http://10.0.50.42:5055
            description: Movie and TV requests
            icon: seerr.png

    - Media Automation:
        - Sonarr:
            href: http://10.0.50.42:8989
            description: TV show automation
            icon: sonarr.png
        - Radarr:
            href: http://10.0.50.42:7878
            description: Movie automation
            icon: radarr.png
        - Lidarr:
            href: http://10.0.50.42:8686
            description: Music automation
            icon: lidarr.png
        - Bazarr:
            href: http://10.0.50.42:6767
            description: Subtitles automation
            icon: bazarr.png
        - Prowlarr:
            href: http://10.0.50.42:9696
            description: Indexer manager
            icon: prowlarr.png

    - Downloads:
        - qBittorrent:
            href: http://10.0.50.42:1338
            description: BitTorrent client
            icon: qbittorrent.png
        - Flood:
            href: http://10.0.50.42:1337
            description: rTorrent web UI
            icon: flood.png
        - FlareSolverr:
            href: http://10.0.50.42:8191
            description: Cloudflare bypass proxy
            icon: flaresolverr.png

    - Productivity:
        - Home Assistant:
            href: http://10.0.50.123:8123
            description: Smart home automation
            icon: home-assistant.png
        - Zigbee2MQTT:
            href: http://10.0.50.124:8080
            description: Zigbee gateway
            icon: zigbee2mqtt.png
        - Paperless:
            href: http://10.0.50.42:1619
            description: Document management
            icon: paperless-ngx.png
        - Tiny Tiny RSS:
            href: http://10.0.50.42:8280
            description: RSS reader
            icon: tinytinyrss.png
        - Fava:
            href: http://10.0.50.42:1601
            description: Beancount double-entry accounting

    - Network:
        - UniFi:
            href: https://10.0.50.42:8443
            description: Network controller
            icon: unifi.png
        - SearXNG:
            href: http://10.0.50.42:8888
            description: Meta search engine
            icon: searxng.png
        - OpenSpeedTest:
            href: http://10.0.50.42:8337
            description: Network speed test
            icon: openspeedtest.png
        - Forgejo:
            href: https://git.iuseneovim.fyi
            description: Git hosting
            icon: forgejo.png
  '';
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "ghcr.io/gethomepage/homepage:v1";
      pull = "newer";
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = ["--network=host"];
      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "10.0.50.42:8069";
        PORT = "8069";
      };
      volumes = [
        "${settingsYaml}:/app/config/settings.yaml:ro"
        "${servicesYaml}:/app/config/services.yaml:ro"
      ];
      environmentFiles = [
        "/persist/services/${serviceName}/secrets.env"
      ];
    };
  };

  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = serviceId;
    group = serviceName;
    home = "/var/lib/${serviceName}";
    createHome = true;
    subUidRanges = [
      {
        count = 65536;
        startUid = serviceId * 100000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = serviceId * 100000;
      }
    ];
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    8069
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /var/lib/${serviceName}
    chown ${uid}:${gid} /var/lib/${serviceName}
    chmod 750 /var/lib/${serviceName}
    mkdir -p /persist/services/${serviceName}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 600 /persist/services/${serviceName}/secrets.env
  '';

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/${serviceName}/.local/share/containers";
      user = serviceName;
      group = serviceName;
      mode = "0700";
    }
  ];
}
