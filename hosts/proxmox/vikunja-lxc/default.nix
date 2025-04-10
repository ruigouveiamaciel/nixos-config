{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    vikunja = {
      image = "vikunja/vikunja@sha256:ed1f3ed467fecec0b57e9de7bc6607f8bbcbb23ffced6a81f5dfefc794cdbe3b";
      ports = ["8080:3456"];
      environmentFiles = [
        config.sops.templates."vikunja-mailer.env".path
      ];
      environment = {
        TZ = config.time.timeZone;
        VIKUNJA_MAILER_ENABLED = "true";
        VIKUNJA_MAILER_HOST = "smtp.protonmail.ch";
        VIKUNJA_MAILER_PORT = "587";
        VIKUNJA_MAILER_AUTHTYPE = "plain";
        VIKUNJA_MAILER_USERNAME = "noreply@maciel.sh";
        VIKUNJA_MAILER_FROMEMAIL = "noreply@maciel.sh";
      };
      volumes = [
        "files:/files"
        "database:/db"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];

  sops = {
    secrets.smtp-password.sopsFile = ./secrets.yaml;

    templates."vikunja-mailer.env" = {
      restartUnits = [
        "${config.virtualisation.oci-containers.containers.vikunja.serviceName}.service"
      ];
      content = ''
        VIKUNJA_MAILER_PASSWORD=${config.sops.placeholder.smtp-password}
      '';
    };
  };

  systemd.services."${config.virtualisation.oci-containers.containers.vikunja.serviceName}".after = [
    "sops-nix.service"
  ];
}
