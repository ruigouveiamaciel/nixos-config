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
        "plugdev"
      ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./yubikeys/cardno_18_657_927.pub)
      (builtins.readFile ./yubikeys/shenzhou.pub)
    ];
    hashedPasswordFile = config.sops.secrets.rui-password.path;
    packages = [pkgs.home-manager];
  };

  home-manager.users.rui = import ./home-manager/configs/${config.networking.hostName};

  sops.secrets.rui-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  # Pass through extra arguments into home-manager. Useful for things like
  # passing through sops secrets
  home-manager.extraSpecialArgs = {
    secrets = {};
  };
}
