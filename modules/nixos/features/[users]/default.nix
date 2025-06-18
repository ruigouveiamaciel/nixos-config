{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.myNixOS.users;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options = {
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          authorizedKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of auhtorized ssh keys";
          };

          homeManagerConfigFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "The path for this user's home manager config";
          };

          extraHomeManagerConfigFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "The path for this user's extra home manager config";
          };

          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional groups for the user";
          };

          extraSettings = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Additional settings for the user";
          };
        };
      });
      default = [];
      description = "List of user configurations";
    };
  };

  config = {
    users = {
      mutableUsers = builtins.length (builtins.attrNames cfg.users) > 0;
      users =
        builtins.mapAttrs (
          name: user:
            {
              description = name;
              openssh.authorizedKeys.keys = lib.mkIf (user.authorizedKeys != null) user.authorizedKeys;
              isNormalUser = true;
              extraGroups = lib.mkIf (user.extraGroups != null) (ifTheyExist user.extraGroups);
              packages = lib.mkIf (user.homeManagerConfigFile != null) [pkgs.home-manager];
            }
            // user.extraSettings
        )
        cfg.users;
    };
    home-manager = lib.mkIf config.myNixOS.nix.home-manager.enable {
      users = builtins.mapAttrs (
        _: user: {
          imports = [
            user.homeManagerConfigFile
            user.extraHomeManagerConfigFile
          ];
        }
      ) (inputs.nixpkgs.lib.filterAttrs (_: user: user.homeManagerConfigFile != null) cfg.users);
    };
  };
}
