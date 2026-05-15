{
  lib,
  myLib,
  ...
}: {
  options = {
    myConstants.users.smokewow = {
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
