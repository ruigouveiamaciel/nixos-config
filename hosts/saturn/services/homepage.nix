{
  inputs,
  outputs,
  myModulesPath,
  ...
}: {
  containers.homepage = {
    autoStart = true;
    macvlans = ["enp90s0"];
    extraFlags = ["-U"];
    bindMounts."/persist/ssh_host_ed25519_key".isReadOnly = true;
    specialArgs = {
      inherit inputs outputs myModulesPath;
    };
    config = {
      pkgs,
      config,
      inputs,
      myModulesPath,
      ...
    }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        "${myModulesPath}/system/nixpkgs.nix"
      ];

      system.stateVersion = "25.11";

      networking = {
        interfaces."mv-enp90s0" = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.0.50.254";
              prefixLength = 24;
            }
          ];
        };
        defaultGateway = "10.0.50.1";
        nameservers = ["10.0.50.1"];
        useHostResolvConf = false;
      };

      services.homepage-dashboard = {
        enable = true;
        package = pkgs.unstable.homepage-dashboard;
        openFirewall = true;
        listenPort = 80;
        environmentFile = config.sops.templates."homepage.env".path;
        settings = {
          headerStyle = "clean";
          useEqualHeights = true;
          hideVersion = true;
          disableUpdateCheck = true;
        };
      };

      sops = {
        age.keyFile = "/persist/ssh_host_ed25519_key";
        secrets = {
          # proxmox-username.sopsFile = ./secrets.yaml;
          # proxmox-password.sopsFile = ./secrets.yaml;
          # unifi-username.sopsFile = ./secrets.yaml;
          # unifi-password.sopsFile = ./secrets.yaml;
          # flood-username.sopsFile = ./secrets.yaml;
          # flood-password.sopsFile = ./secrets.yaml;
          # jellyfin-key.sopsFile = ./secrets.yaml;
          # radarr-key.sopsFile = ./secrets.yaml;
          # sonarr-key.sopsFile = ./secrets.yaml;
          # bazarr-key.sopsFile = ./secrets.yaml;
          # prowlarr-key.sopsFile = ./secrets.yaml;
          # jellyseerr-key.sopsFile = ./secrets.yaml;
          # immich-key.sopsFile = ./secrets.yaml;
          # paperless-key.sopsFile = ./secrets.yaml;
          # vikunja-key.sopsFile = ./secrets.yaml;
        };

        templates."homepage.env" = {
          restartUnits = ["homepage-dashboard.service"];
          content = ''
            HOMEPAGE_ALLOWED_HOSTS=http://10.0.50.254
          '';
          # content = ''
          #   HOMEPAGE_VAR_PROXMOX_USERNAME=${config.sops.placeholder.proxmox-username}
          #   HOMEPAGE_VAR_PROXMOX_PASSWORD=${config.sops.placeholder.proxmox-password}
          #   HOMEPAGE_VAR_UNIFI_USERNAME=${config.sops.placeholder.unifi-username}
          #   HOMEPAGE_VAR_UNIFI_PASSWORD=${config.sops.placeholder.unifi-password}
          #   HOMEPAGE_VAR_FLOOD_USERNAME=${config.sops.placeholder.flood-username}
          #   HOMEPAGE_VAR_FLOOD_PASSWORD=${config.sops.placeholder.flood-password}
          #   HOMEPAGE_VAR_JELLYFIN_KEY=${config.sops.placeholder.jellyfin-key}
          #   HOMEPAGE_VAR_RADARR_KEY=${config.sops.placeholder.radarr-key}
          #   HOMEPAGE_VAR_SONARR_KEY=${config.sops.placeholder.sonarr-key}
          #   HOMEPAGE_VAR_BAZARR_KEY=${config.sops.placeholder.bazarr-key}
          #   HOMEPAGE_VAR_PROWLARR_KEY=${config.sops.placeholder.prowlarr-key}
          #   HOMEPAGE_VAR_JELLYSEERR_KEY=${config.sops.placeholder.jellyseerr-key}
          #   HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder.immich-key}
          #   HOMEPAGE_VAR_PAPERLESS_KEY=${config.sops.placeholder.paperless-key}
          #   HOMEPAGE_VAR_VIKUNJA_KEY=${config.sops.placeholder.vikunja-key}
          # '';
        };
      };
    };
  };
}
