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
      image = "itzg/minecraft-server@sha256:eff50e31e26aa2a5f0c84ee83496f0a9f92743fafc7876760a6be7ea7a462c74";
      extraOptions = [
        "--network=atm9_network"
      ];
      environmentFiles = [
        config.sops.templates."atm9-secrets.env".path
      ];
      volumes = [
        "/persist/services/atm9/data:/data"
        "${config.sops.templates."atm9-whitelist.json"}:/data/whitelist.json"
        "${config.sops.templates."atm9-ops.json"}:/data/ops.json"
        "${config.sops.templates."atm9-simplebackups-common.toml"}:/data/config/simplebackups-common.toml"
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

  sops.templates."atm9-whitelist.json".content = ''
    [
      {
        "uuid": "350a704c-35f7-4da8-801b-e9903fe1256a",
        "name": "SmOkEwOw_"
      },
      {
        "uuid": "9eca5388-6a62-41a6-96e0-6c068829438f",
        "name": "Skjari"
      }
    ]
  '';

  sops.templates."atm9-ops.json".content = ''
    [
      {
        "uuid": "350a704c-35f7-4da8-801b-e9903fe1256a",
        "name": "SmOkEwOw_",
        "level": 4,
        "bypassesPlayerLimit": false
      }
    ]
  '';

  sops.templates."atm9-simplebackups-common.toml".content = ''
    #If set false, no backups are being made.
    enabled = true
    #Defines the backup type.
    #- FULL_BACKUPS - always creates full backups
    #- MODIFIED_SINCE_LAST - only saves the files which changed since last (partial) backup
    #- MODIFIED_SINCE_FULL - saves all files which changed after the last full backup
    #Allowed Values: FULL_BACKUPS, MODIFIED_SINCE_LAST, MODIFIED_SINCE_FULL
    backupType = "FULL_BACKUPS"
    #How often should a full backup be created if only modified files should be saved? This creates a full backup when x minutes are over and the next backup needs to be done. Once a year is default.
    #Range: 1 ~ 5259600
    fullBackupTimer = 525960
    #The max amount of backup files to keep.
    #Range: 1 ~ 32767
    backupsToKeep = 100
    #The time between two backups in minutes
    #5 = each 5 minutes
    #60 = each hour
    #1440 = each day
    #Range: 1 ~ 32767
    timer = 60
    #The compression level, 0 is no compression (less cpu usage) and takes a lot of space, 9 is best compression (most cpu usage) and takes less space. -1 is default
    #Range: -1 ~ 9
    compressionLevel = 9
    #Should message be sent when backup is in the making?
    sendMessages = true
    #The max size of storage the backup folder. If it takes more storage, old files will be deleted.
    #Needs to be written as <number><space><storage type>
    #Valid storage types: B, KB, MB, GB, TB
    maxDiskSize = "500 GB"
    #Used to define the output path.
    outputPath = "simplebackups"

    [mod_compat]
      #Should backup notifications be sent to Discord by using mc2discord? (needs to be installed)
      mc2discord = true
  '';
}
