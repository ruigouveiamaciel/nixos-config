{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = "rui@iuseneovim.fyi";
    userName = "Rui Maciel";
    lfs.enable = true;
  };
}
