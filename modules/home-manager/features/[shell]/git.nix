{pkgs, ...}: {
  config = {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userEmail = "rui@maciel.sh";
      userName = "Rui Maciel";
      lfs.enable = true;
    };
  };
}
