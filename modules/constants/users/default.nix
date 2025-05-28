{
  lib,
  myLib,
  ...
}: {
  options = {
    myConstants.users.rui = {
      authorized-keys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      pgp = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = {
    myConstants.users.rui = {
      authorized-keys = builtins.map (file: builtins.readFile file) (myLib.filesIn ./rui/authorized-keys);
      pgp = builtins.readFile ./rui/pgp.asc;
    };
  };
}
