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
    acc-spa-server = {
      image = "ich777/accompetizione-server@sha256:7fb2970ff491747ca1076d3bd472ad2fb9dbb98d431dbad4bac01dc06947f0d6";
      extraOptions = [
        "--network=acc_network"
      ];
      environment = {
        UID="99";
        GID="100";
        UMASK="000";
        DATA_DIR="/acc";
        DATA_PERM="770";
      };
      volumes = [
        "/nix/backup/services/acc/accServer.exe:/acc/accServer.exe"
        "${config.sops.templates."acc-configuration.json".path}:/acc/cfg/configuration.json"
        "${config.sops.templates."acc-spa-settings.json".path}:/acc/cfg/settings.json"
        "${config.sops.templates."acc-eventRules.json".path}:/acc/cfg/eventRules.json"
        "${config.sops.templates."acc-spa-event.json".path}:/acc/cfg/event.json"
      ];
      ports = [
        "9201:9201"
        "9201:9201/udp"
      ];
    };
    acc-monza-server = {
      image = "ich777/accompetizione-server@sha256:7fb2970ff491747ca1076d3bd472ad2fb9dbb98d431dbad4bac01dc06947f0d6";
      extraOptions = [
        "--network=acc_network"
      ];
      environment = {
        UID="99";
        GID="100";
        UMASK="000";
        DATA_DIR="/acc";
        DATA_PERM="770";
      };
      volumes = [
        "/nix/backup/services/acc/accServer.exe:/acc/accServer.exe"
        "${config.sops.templates."acc-configuration.json".path}:/acc/cfg/configuration.json"
        "${config.sops.templates."acc-monza-settings.json".path}:/acc/cfg/settings.json"
        "${config.sops.templates."acc-eventRules.json".path}:/acc/cfg/eventRules.json"
        "${config.sops.templates."acc-monza-event.json".path}:/acc/cfg/event.json"
      ];
      ports = [
        "9202:9201"
        "9202:9201/udp"
      ];
    };
  };

  systemd.services.prepare-acc-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-acc-monza-server.service"
      "${backend}-acc-spa-server.service"
    ];
    script = ''
      mkdir -p /nix/backup/services/acc
      ${backendBin} network inspect acc_network >/dev/null 2>&1 || ${backendBin} network create acc_network
    '';
  };

  networking.firewall.allowedUDPPorts = [
    9201
    9202
  ];

  networking.firewall.allowedTCPPorts = [
    9201
    9202
  ];

  sops.templates."acc-spa-settings.json".content = ''
    {
      "serverName": "SmOkEwOw Spa ACC Server",
      "adminPassword": "frigorifico",
      "carGroup": "FreeForAll",
      "trackMedalsRequirement": 0,
      "safetyRatingRequirement": -1,
      "racecraftRatingRequirement": -1,
      "password": "",
      "spectatorPassword": "",
      "dumpLeaderboards": 0,
      "dumpEntryList": 0,
      "isRaceLocked": 0,
      "shortFormationLap": 1,
      "formationLapType": 3,
      "doDriverSwapBroadcast": 1,
      "centralEntryListPath": "",
      "ignorePrematureDisconnects": 0,
      "allowAutoDQ": 0,
      "configVersion": 1
  }
  '';

  sops.templates."acc-monza-settings.json".content = ''
    {
      "serverName": "SmOkEwOw Monza ACC Server",
      "adminPassword": "frigorifico",
      "carGroup": "FreeForAll",
      "trackMedalsRequirement": 0,
      "safetyRatingRequirement": -1,
      "racecraftRatingRequirement": -1,
      "password": "",
      "spectatorPassword": "",
      "dumpLeaderboards": 0,
      "dumpEntryList": 0,
      "isRaceLocked": 0,
      "shortFormationLap": 1,
      "formationLapType": 3,
      "doDriverSwapBroadcast": 1,
      "centralEntryListPath": "",
      "ignorePrematureDisconnects": 0,
      "allowAutoDQ": 0,
      "configVersion": 1
  }
  '';

  sops.templates."acc-configuration.json".content = ''
    {
      "udpPort": 9201,
      "tcpPort": 9201,
      "maxConnections": 10,
      "registerToLobby": 1,
      "configVersion": 1
    }
  '';

  sops.templates."acc-eventRules.json".content = ''
    {
        "qualifyStandingType": 1,
        "superpoleMaxCar": -1,
        "pitWindowLengthSec": -1,
        "driverStintTimeSec": -1,
        "isRefuellingAllowedInRace": true,
        "isRefuellingTimeFixed": false,
        "maxDriversCount": 1,
        "mandatoryPitstopCount": 0,
        "maxTotalDrivingTime": -1,
        "isMandatoryPitstopRefuellingRequired": false,
        "isMandatoryPitstopTyreChangeRequired": false,
        "isMandatoryPitstopSwapDriverRequired": false,
        "tyreSetCount": 50
    }
  '';

  sops.templates."acc-monza-event.json".content = ''
    {
        "track": "monza",
        "eventType": "E_6h",
        "preRaceWaitingTimeSeconds": 80,
        "postQualySeconds": 10,
        "postRaceSeconds": 10,
        "sessionOverTimeSeconds": 150,
        "ambientTemp": 25,
        "trackTemp": 25,
        "cloudLevel": 0.3,
        "rain": 0.0,
        "weatherRandomness": 0,
        "sessions": [
            {
                "hourOfDay": 14,
                "dayOfWeekend": 2,
                "timeMultiplier": 1,
                "sessionType": "Q",
                "sessionDurationMinutes": 10
            },
            {
                "hourOfDay": 14,
                "dayOfWeekend": 3,
                "timeMultiplier": 1,
                "sessionType": "R",
                "sessionDurationMinutes": 15
            }
        ],
        "configVersion": 1
    }
  '';

  sops.templates."acc-spa-event.json".content = ''
    {
        "track": "spa",
        "eventType": "E_6h",
        "preRaceWaitingTimeSeconds": 80,
        "postQualySeconds": 10,
        "postRaceSeconds": 10,
        "sessionOverTimeSeconds": 150,
        "ambientTemp": 25,
        "trackTemp": 25,
        "cloudLevel": 0.3,
        "rain": 0.0,
        "weatherRandomness": 0,
        "sessions": [
            {
                "hourOfDay": 14,
                "dayOfWeekend": 2,
                "timeMultiplier": 1,
                "sessionType": "Q",
                "sessionDurationMinutes": 10
            },
            {
                "hourOfDay": 14,
                "dayOfWeekend": 3,
                "timeMultiplier": 1,
                "sessionType": "R",
                "sessionDurationMinutes": 15
            }
        ],
        "configVersion": 1
    }
  '';
}
