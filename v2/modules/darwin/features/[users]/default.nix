{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.myDarwin.users;
in {
  imports = [
    inputs.home-manager.darwinModules.home-manager
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
      users =
        builtins.mapAttrs (
          _name: user:
            {
              openssh.authorizedKeys.keys = lib.mkIf (user.authorizedKeys != null) user.authorizedKeys;
              packages = lib.mkIf (user.homeManagerConfigFile != null) [pkgs.home-manager];
            }
            // user.extraSettings
        )
        cfg.users;
    };
    home-manager = lib.mkIf config.myDarwin.nix.home-manager.enable {
      users = builtins.mapAttrs (
        _: user:
          import user.homeManagerConfigFile
      ) (inputs.nixpkgs.lib.filterAttrs (_: user: user.homeManagerConfigFile != null) cfg.users);
    };
  };
}
