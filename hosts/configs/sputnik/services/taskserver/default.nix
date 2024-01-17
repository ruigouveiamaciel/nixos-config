{
  pkgs,
  config,
  ...
}: {
  services.taskserver = {
    enable = true;
    openFirewall = true;
    fqdn = "taskserver.maciel.sh";
    listenHost = "192.168.1.76";
    listenPort = 49591;
    dataDir = "/nix/backup/services/taskserver";
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
