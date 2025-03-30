{config, ...}: {
  imports = [../minimal-lxc];

  virtualisation.oci-containers.containers = {
    vikunja = {
      image = "vikunja/vikunja@sha256:ed1f3ed467fecec0b57e9de7bc6607f8bbcbb23ffced6a81f5dfefc794cdbe3b";
      ports = ["8080:3456"];
      environment = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "files:/files"
        "database:/db"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
