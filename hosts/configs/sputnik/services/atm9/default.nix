{
  pkgs,
  config,
  self,
  ...
}: let
  backend = config.virtualisation.oci-containers.backend;
  backendBin = "${pkgs.${backend}}/bin/${backend}";
in {
  virtualisation.oci-containers.containers = {
    atm9-minecraft-server = {
      image = "itzg/minecraft-server@sha256:0536b2d59e98ab5980571310a87b14d51e9b965fc881ea4bd4d8d1ee93defb1d";
      extraOptions = [
        "--network=atm9_network"
      ];
      environmentFiles = [
        config.sops.templates."atm9-secrets.env".path
      ];
      volumes = [
        "/nix/backup/services/atm9/data:/data"
        "/nix/backup/services/atm9/downloads:/downloads"
      ];
      ports = [
        "25565:25565"
      ];
    };
  };

  systemd.services.prepare-atm9-minecraft-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-atm9-minecraft-server.service"
    ];
    script = ''
      mkdir -p /nix/backup/services/atm9/data
      mkdir -p /nix/backup/services/atm9/downloads
      ${backendBin} network inspect atm9_network >/dev/null 2>&1 || ${backendBin} network create atm9_network
    '';
  };
  
  sops.secrets.curseforge-api-key = {
    sopsFile = ../../secrets.yaml;
  };

  sops.templates."atm9-secrets.env".content = ''
    EULA=true
    MOD_PLATFORM=AUTO_CURSEFORGE
    CF_PAGE_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-9
    CF_FILENAME_MATCHER="0.2.34"
    MEMORY=8G
    CF_API_KEY=${config.sops.placeholder.curseforge-api-key}
  '';
}
