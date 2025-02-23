{config, ...}: let
  inherit (config.virtualisation.oci-containers) backend;
  backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
  networkName = "sshwifty";
in {
  networking.firewall.allowedTCPPorts = [80];

  virtualisation.oci-containers.containers = {
    sshwifty = {
      image = "niruix/sshwifty@sha256:837fd62b5cccab6ca2233058b2c5e001f1aae434e2a97f7c2da4307b01460b0e";
      extraOptions = ["--network=${networkName}"];
      dependsOn = ["sshwifty-cloudflared-tunnel"];
      volumes = ["${config.sops.templates."sshwifty.conf.json".path}:/sshwifty.conf.json:ro"];
      environment = {
        SSHWIFTY_CONFIG = "/sshwifty.conf.json";
      };
      ports = ["80:80"];
    };
    sshwifty-cloudflared-tunnel = {
      inherit (config.myNixOS.networking.cloudflared) image;
      extraOptions = ["--network=${networkName}"];
      cmd = ["tunnel" "run"];
      environmentFiles = [
        config.sops.templates."sshwifty-cloudflared-tunnel.env".path
      ];
    };
  };

  systemd.services.prepare-sshwifty = rec {
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "yes";

    requiredBy = [
      "${backend}-sshwifty.service"
      "${backend}-sshwifty-cloudflared-tunnel.service"
    ];
    before = requiredBy;
    requires = ["${backend}.socket"];
    after = ["sops-nix.service"];
    script = ''
      if ${backendBin} network inspect ${networkName}; then
        exit 0
      fi
      ${backendBin} network create ${networkName}
    '';
  };

  sops = {
    secrets = {
      sshwifty-cloudflared-tunnel-token.sopsFile = ./secrets.yaml;
      devbox-ssh-password.sopsFile = ./secrets.yaml;
    };

    templates = {
      "sshwifty-cloudflared-tunnel.env".content = ''
        TUNNEL_TOKEN=${config.sops.placeholder.sshwifty-cloudflared-tunnel-token}
      '';

      "sshwifty.conf.json".content =
        /*
        js
        */
        ''
          {
            "HostName": "sshwifty.maciel.sh",
            "SharedKey": "",
            "DialTimeout": 10,
            "Servers": [
              {
                "ListenInterface": "0.0.0.0",
                "ListenPort": 80,
                "InitialTimeout": 3,
                "ReadTimeout": 60,
                "WriteTimeout": 60,
                "HeartbeatTimeout": 20,
                "ReadDelay": 10,
                "WriteDelay": 10,
                "TLSCertificateFile": "",
                "TLSCertificateKeyFile": "",
                "ServerMessage": ""
              }
            ],

            "Presets": [
              {
                "Title": "devbox",
                "Type": "SSH",
                "Host": "devbox:22",
                "Meta": {
                  "User": "rui",
                  "Encoding": "utf-8",
                  "Authentication": "Password",
                  "Password": ${config.sops.placeholder.devbox-ssh-password},
                  "Fingerprint": "SHA256:AAAAC3NzaC1lZDI1NTE5AAAAIObBweK+ieHyoKIJrX90bIO++VF6BABudTJgOEfwz0Ct"
                }
              }
            ],

            "OnlyAllowPresetRemotes": true
          }
        '';
    };
  };
}
