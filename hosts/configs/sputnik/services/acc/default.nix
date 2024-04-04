{
  pkgs,
  config,
  self,
  lib,
  ...
}: let
  backend = config.virtualisation.oci-containers.backend;
  backendBin = "${pkgs.${backend}}/bin/${backend}";

  servers = {
    monza-amateur = {
      name = "Monza Amateur";
      track = "monza";
      port = 9201;
      maxCarSlots = 10;
      trackMedalsRequirement = 0;
      safetyRatingRequirement = -1;
      qualifyingDuration = 10;
      raceDuration = 15;
      sessionOverTimeSeconds = 120;
    };
    spa-amateur = {
      name = "Spa Amateur";
      track = "spa";
      port = 9202;
      maxCarSlots = 10;
      trackMedalsRequirement = 0;
      safetyRatingRequirement = -1;
      qualifyingDuration = 10;
      raceDuration = 15;
      sessionOverTimeSeconds = 150;
    };
    monza-intermediate = {
      name = "Monza Intermediate";
      track = "monza";
      port = 9203;
      maxCarSlots = 20;
      trackMedalsRequirement = 3;
      safetyRatingRequirement = 50;
      qualifyingDuration = 15;
      raceDuration = 20;
      sessionOverTimeSeconds = 120;
    };
    spa-intermediate = {
      name = "Spa Intermediate";
      track = "spa";
      port = 9204;
      maxCarSlots = 20;
      trackMedalsRequirement = 3;
      safetyRatingRequirement = 50;
      qualifyingDuration = 15;
      raceDuration = 20;
      sessionOverTimeSeconds = 150;
    };
    nurburgring-24h = {
      name = "Nurburgring 24h";
      track = "nurburgring_24h";
      port = 9205;
      maxCarSlots = 27;
      trackMedalsRequirement = 0;
      safetyRatingRequirement = 70;
      qualifyingDuration = 12;
      raceDuration = 30;
      sessionOverTimeSeconds = 600;
    };
  };
in {
  virtualisation.oci-containers.containers = builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: server: {
      name = "acc-${name}-server";
      value = {
        image = "ich777/accompetizione-server@sha256:7fb2970ff491747ca1076d3bd472ad2fb9dbb98d431dbad4bac01dc06947f0d6";
        extraOptions = [
          "--network=acc_network"
        ];
        environment = {
          UID = "99";
          GID = "100";
          UMASK = "000";
          DATA_DIR = "/acc";
          DATA_PERM = "770";
        };
        volumes = [
          "/persist/services/acc/accServer.exe:/acc/accServer.exe"
          "/persist/services/acc/results:/acc/results"
          "${config.sops.templates."acc-${name}-configuration.json".path}:/acc/cfg/configuration.json"
          "${config.sops.templates."acc-${name}-settings.json".path}:/acc/cfg/settings.json"
          "${config.sops.templates."acc-${name}-event.json".path}:/acc/cfg/event.json"
          "${config.sops.templates."acc-${name}-eventRules.json".path}:/acc/cfg/eventRules.json"
          "${config.sops.templates."acc-entrylist.json".path}:/acc/cfg/entrylist.json"
        ];
        ports = [
          "${builtins.toString server.port}:${builtins.toString server.port}"
          "${builtins.toString server.port}:${builtins.toString server.port}/udp"
        ];
      };
    })
    servers));

  systemd.services.prepare-acc-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = builtins.map (x: "${backend}-${x}-server.service") (builtins.attrNames servers);
    before = builtins.map (x: "${backend}-${x}-server.service") (builtins.attrNames servers);
    script = ''
      mkdir -p /persist/services/acc/results
      chown -R 99:100 /persist/services/acc
      chmod -R 770 /persist/services/acc
      ${backendBin} network inspect acc_network >/dev/null 2>&1 || ${backendBin} network create acc_network
    '';
  };

  networking.firewall.allowedUDPPorts = builtins.map (x: x.port) (builtins.attrValues servers);
  networking.firewall.allowedTCPPorts = builtins.map (x: x.port) (builtins.attrValues servers);

  sops.templates =
    builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
        name = "acc-${name}-settings.json";
        value = {
          content = ''
            {
              "serverName": "SmOkEwOw ${value.name}",
              "adminPassword": "${config.sops.placeholder.acc-admin-password}",
              "carGroup": "FreeForAll",
              "trackMedalsRequirement": ${builtins.toString value.trackMedalsRequirement},
              "safetyRatingRequirement": ${builtins.toString value.safetyRatingRequirement},
              "maxCarSlots": ${builtins.toString value.maxCarSlots},
              "spectatorPassword": "${config.sops.placeholder.acc-spectator-password}",
              "dumpLeaderboards": 1,
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
        };
      })
      servers))
    // builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
        name = "acc-${name}-configuration.json";
        value = {
          content = ''
            {
              "udpPort": ${builtins.toString value.port},
              "tcpPort": ${builtins.toString value.port},
              "maxConnections": ${builtins.toString (value.maxCarSlots + 5)},
              "registerToLobby": 1,
              "configVersion": 1
            }
          '';
        };
      })
      servers))
    // builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
        name = "acc-${name}-event.json";
        value = {
          content = ''
            {
                "track": "${value.track}",
                "eventType": "E_6h",
                "preRaceWaitingTimeSeconds": 80,
                "postQualySeconds": 10,
                "postRaceSeconds": 10,
                "sessionOverTimeSeconds": ${builtins.toString value.sessionOverTimeSeconds},
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
                        "sessionDurationMinutes": ${builtins.toString value.qualifyingDuration}
                    },
                    {
                        "hourOfDay": 14,
                        "dayOfWeekend": 3,
                        "timeMultiplier": 1,
                        "sessionType": "R",
                        "sessionDurationMinutes": ${builtins.toString value.raceDuration}
                    }
                ],
                "configVersion": 1
            }
          '';
        };
      })
      servers))
    // builtins.listToAttrs (builtins.attrValues (builtins.mapAttrs (name: value: {
        name = "acc-${name}-eventRules.json";
        value = {
          content = ''
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
        };
      })
      servers))
    // {
      "acc-entrylist.json".content = ''
        {
          "forceEntryList": 0,
          "entries": [
            {
              "drivers": [
                {
                  "playerID": "S76561198080832770"
                }
              ],
              "raceNumber": 69,
              "forcedCarModel": -1,
              "overrideDriverInfo": 0,
              "isServerAdmin": 1
            },
            {
              "drivers": [
                {
                  "playerID": "S76561198253686407"
                }
              ],
              "raceNumber": 420,
              "forcedCarModel": -1,
              "overrideDriverInfo": 0,
              "isServerAdmin": 0
            },
            {
              "drivers": [
                {
                  "playerID": "S76561198994294106"
                }
              ],
              "raceNumber": 7,
              "forcedCarModel": -1,
              "overrideDriverInfo": 0,
              "isServerAdmin": 0
            },
            {
              "drivers": [
                {
                  "playerID": "S76561199003020183"
                }
              ],
              "raceNumber": 1,
              "forcedCarModel": -1,
              "overrideDriverInfo": 0,
              "isServerAdmin": 0
            },
            {
              "drivers": [
                {
                  "playerID": "S76561198007092868"
                }
              ],
              "raceNumber": 27,
              "forcedCarModel": -1,
              "overrideDriverInfo": 0,
              "isServerAdmin": 0
            }
          ]
        }
      '';
    };

  sops.secrets.acc-admin-password = {
    sopsFile = ../../secrets.yaml;
  };

  sops.secrets.acc-spectator-password = {
    sopsFile = ../../secrets.yaml;
  };
}
