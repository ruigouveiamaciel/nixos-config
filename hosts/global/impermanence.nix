{
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence = {
    "/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/bluetooth" # Bluetooth devices
        "/var/lib/systemd/coredump" # Core dumps
        "/var/lib/nixos" # NixOS stuff
        "/var/log" # Logs
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  system.activationScripts.persistent-homes.text = let
    mkHomePersist = user:
      lib.optionalString user.createHome ''
        mkdir -p /nix/persist/${user.home}
        chown ${user.name}:${user.group} /nix/persist/${user.home}
        chmod ${user.homeMode} /nix/persist/${user.home}
        mkdir -p /nix/backup/${user.home}
        chown ${user.name}:${user.group} /nix/backup/${user.home}
        chmod ${user.homeMode} /nix/backup/${user.home}
      '';
    users = lib.attrValues config.users.users;
  in
    lib.concatLines (map mkHomePersist users);
}
