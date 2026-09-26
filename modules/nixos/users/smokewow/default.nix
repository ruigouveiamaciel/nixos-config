{
  config,
  myModulesPath,
  lib,
  options,
  ...
}: let
  filterUnexistentGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    "${myModulesPath}/shell/fish.nix"
    "${myModulesPath}/system/home-manager.nix"
    "${myModulesPath}/desktop/voyager.nix"
  ];

  config = lib.mkMerge ([
      {
        boot.postBootCommands = let
          uid = builtins.toString config.users.users.smokewow.uid;
          gid = builtins.toString config.users.groups."${config.users.users.smokewow.group}".gid;
        in ''
          mkdir -p ${config.users.users.smokewow.home}
          chown -R ${uid}:${gid} ${config.users.users.smokewow.home}
          chmod 750 ${config.users.users.smokewow.home}
          chmod -R g-w,o-rwx ${config.users.users.smokewow.home}
        '';

        users = {
          users.smokewow = {
            uid = 1069;
            group = "users";
            home = "/home/smokewow";
            description = "SmOkEwOw";
            openssh.authorizedKeys.keys = config.myConstants.users.smokewow.authorized-keys;
            isNormalUser = true;
            extraGroups = filterUnexistentGroups [
              "wheel"
              "audio"
              "video"
              "render"
              "docker"
              "podman"
              "dialout"
              "plugdev"
              "networkmanager"
              "kvm"
            ];
            shell = config.programs.fish.package;
            hashedPassword = "";
          };
        };
      }
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.users.smokewow.imports = [
        ./home.nix
      ];
    }));
}
