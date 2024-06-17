{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = "ruigouveiamaciel@proton.me";
    userName = "Rui Maciel";
    lfs.enable = true;
    signing = {
      key = "308155094625A2F5BA83D78EC1FEBB4FA9C3AC52";
      signByDefault = !config.wsl.enable;
    };
  };
}
