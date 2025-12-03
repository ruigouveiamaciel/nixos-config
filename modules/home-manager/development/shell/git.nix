{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    settings = {
      user = {
        email = "rui@iuseneovim.fyi";
        name = "Rui Maciel";
      };
    };
  };
}
