{
  pkgs,
  config,
  self,
  lib,
  ...
}: let
  backend = config.virtualisation.oci-containers.backend;
  backendBin = "${pkgs.${backend}}/bin/${backend}";
in {
  virtualisation.oci-containers.containers = {
    atm9-minecraft-server = {
      image = "itzg/minecraft-server@sha256:e375502625e9ab27357ef15670f9c3030305bfd4ef151bb6629418223a10b987";
      extraOptions = [
        "--network=atm9_network"
      ];
      environmentFiles = [
        config.sops.templates."atm9-secrets.env".path
      ];
      volumes = [
        "/persist/services/atm9/data:/data"
        "/persist/services/atm9/downloads:/downloads"
      ];
      ports = [
        "25000:25565"
      ];
    };
  };

  systemd.services.prepare-atm9-minecraft-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-atm9-minecraft-server.service"
    ];
    before = [
      "${backend}-atm9-minecraft-server.service"
    ];
    script = ''
      mkdir -p /persist/services/atm9/data
      mkdir -p /persist/services/atm9/downloads
      chown -R 1000:1000 /persist/services/atm9/data
      chown -R 0:0 /persist/services/atm9/downloads
      chmod -R 755 /persist/services/atm9/data
      chmod -R 755 /persist/services/atm9/downloads
      ${backendBin} network inspect atm9_network >/dev/null 2>&1 || ${backendBin} network create atm9_network
    '';
  };

  networking.firewall.allowedUDPPorts = [
    25000
  ];

  networking.firewall.allowedTCPPorts = [
    25000
  ];

  sops.secrets.curseforge-api-key = {
    sopsFile = ../../secrets.yaml;
  };

  sops.templates."atm9-secrets.env".content = ''
    EULA=true
    MOD_PLATFORM=AUTO_CURSEFORGE
    CF_PAGE_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-9
    CF_FILENAME_MATCHER=0.2.54
    MEMORY=16G
    CF_API_KEY=${config.sops.placeholder.curseforge-api-key}
  '';
}
