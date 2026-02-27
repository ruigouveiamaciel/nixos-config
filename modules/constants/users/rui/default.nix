{
  lib,
  myLib,
  ...
}: {
  options = {
    myConstants.users.rui = {
      authorized-keys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = builtins.map (file: builtins.readFile file) (myLib.filesIn ./authorized-keys);
      };
      pgp = lib.mkOption {
        type = lib.types.path;
        default = ./smokewow.asc;
      };
    };
  };
}
