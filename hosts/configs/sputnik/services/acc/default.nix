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
    acc-server = {
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
        "/nix/backup/services/acc:/acc"
      ];
      ports = [
        "9206:9201"
      ];
    };
  };

  systemd.services.prepare-acc-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-acc-server.service"
    ];
    script = ''
      mkdir -p /nix/backup/services/acc
      ${backendBin} network inspect acc_network >/dev/null 2>&1 || ${backendBin} network create acc_network
    '';
  };

  networking.firewall.allowedUDPPorts = [
    9206
  ];

  networking.firewall.allowedTCPPorts = [
    9206
  ];
}
