{pkgs, ...}: {
  config = {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userEmail = "ruigouveiamaciel@proton.me";
      userName = "Rui Maciel";
      lfs.enable = true;
      push.autoSetupRemote = true;
    };
  };
}
