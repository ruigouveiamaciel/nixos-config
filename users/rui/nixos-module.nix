{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = false;
  users.users.rui = {
    description = "Rui Maciel";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups =
      [
        "wheel" # Permission to use 'sudo'
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "network"
        "networkmanager"
        "net"
        "docker"
        "podman"
        "git"
        "dialout"
      ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./yubikeys/cardno_18_657_927.pub)
    ];
    hashedPasswordFile = config.sops.secrets.rui-password.path;
    packages = [pkgs.home-manager];
  };

  home-manager.users.rui = import ./home-manager/configs/${config.networking.hostName};

  sops.secrets.rui-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  sops.secrets.rui-taskwarrior-ca-cert = {
    sopsFile = ./secrets.yaml;
    owner = "rui";
    group = config.users.users.rui.group;
    mode = "0440";
  };

  sops.secrets.rui-taskwarrior-cert = {
    sopsFile = ./secrets.yaml;
    owner = "rui";
    group = config.users.users.rui.group;
    mode = "0440";
  };

  sops.secrets.rui-taskwarrior-key = {
    sopsFile = ./secrets.yaml;
    owner = "rui";
    group = config.users.users.rui.group;
    mode = "0440";
  };

  home-manager.extraSpecialArgs = {
    secrets = {
      rui-taskwarrior-ca-cert = config.sops.secrets.rui-taskwarrior-ca-cert.path;
      rui-taskwarrior-cert = config.sops.secrets.rui-taskwarrior-cert.path;
      rui-taskwarrior-key = config.sops.secrets.rui-taskwarrior-key.path;
    };
  };
}
