{
  pkgs,
  config,
  lib,
  ...
}: {
  services.taskserver = {
    enable = true;
    openFirewall = true;
    fqdn = "taskserver.maciel.sh";
    listenHost = "138.201.17.172";
    listenPort = 49591;
    dataDir = "/persist/services/taskserver";
    pki.manual = {
      server.key = config.sops.secrets.taskwarrior-server-key.path;
      server.crl = config.sops.secrets.taskwarrior-server-crl.path;
      server.cert = config.sops.secrets.taskwarrior-server-cert.path;
      ca.cert = config.sops.secrets.taskwarrior-ca-cert.path;
    };
    organisations."family".users = [
      "rui"
    ];
  };

  systemd.services."taskserver" = {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = 3;
    };
  };

  systemd.services.prepare-taskserver = {
    serviceConfig.Type = "oneshot";
    requiredBy = ["taskserver.service"];
    before = ["taskserver.service"];
    script = ''
      mkdir -p /persist/services/taskserver
      chown -R 240:240 /persist/services/taskserver
      chmod -R 770 /persist/services/taskserver
    '';
  };

  sops.secrets.taskwarrior-server-key = {
    sopsFile = ../../secrets.yaml;
    owner = config.services.taskserver.user;
    group = config.services.taskserver.group;
    mode = "0440";
  };

  sops.secrets.taskwarrior-server-crl = {
    sopsFile = ../../secrets.yaml;
    owner = config.services.taskserver.user;
    group = config.services.taskserver.group;
    mode = "0440";
  };

  sops.secrets.taskwarrior-server-cert = {
    sopsFile = ../../secrets.yaml;
    owner = config.services.taskserver.user;
    group = config.services.taskserver.group;
    mode = "0440";
  };

  sops.secrets.taskwarrior-ca-cert = {
    sopsFile = ../../secrets.yaml;
    mode = "0444";
  };
}
