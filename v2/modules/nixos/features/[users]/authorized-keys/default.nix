{
  lib,
  myLib,
  ...
}: {
  options = {
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
    };
  };

  config = {
    myNixOS.users.authorized-keys.users = {
      rui =
        builtins.map (file: builtins.readFile file) (myLib.filesIn ./rui);
    };
  };
}
