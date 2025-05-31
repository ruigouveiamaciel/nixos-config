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
        type = lib.types.path;
      };
      gpg-agent-keygrips = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = {
    myConstants.users.rui = {
      authorized-keys = builtins.map (file: builtins.readFile file) (myLib.filesIn ./rui/authorized-keys);
      pgp = ./rui/pgp.asc;
      gpg-agent-keygrips = ["308155094625A2F5BA83D78EC1FEBB4FA9C3AC52"];
    };
  };
}
