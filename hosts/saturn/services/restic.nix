{
  lib,
  pkgs,
  config,
  ...
}: let
  serviceName = "restic";
  serviceId = 1017;
in {
  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isSystemUser = true;
    uid = serviceId;
    group = serviceName;
    home = "/var/lib/${serviceName}";
    createHome = true;
  };

  security.wrappers.restic = {
    source = lib.getExe pkgs.restic;
    owner = serviceName;
    group = serviceName;
    permissions = "500";
    capabilities = "cap_dac_read_search+ep";
  };

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}
    touch /persist/services/${serviceName}/secrets.env
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 /persist/services/${serviceName}
    chmod 600 /persist/services/${serviceName}/secrets.env
  '';

  services.restic.backups.default = {
    user = serviceName;
    package = pkgs.writeShellScriptBin "restic" ''
      exec /run/wrappers/bin/restic "$@"
    '';
    initialize = true;
    environmentFile = "/persist/services/${serviceName}/secrets.env";
    timerConfig = {
      OnCalendar = "05:05";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
    paths = [
      "/persist/services"
      "/persist/media/personal"
      "/persist/nixos-config"
    ];
    exclude = [
      "/persist/services/*/*.env"
      "/persist/services/${serviceName}"
      "/persist/services/forgejo/data/git/repositories/mirrors"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
