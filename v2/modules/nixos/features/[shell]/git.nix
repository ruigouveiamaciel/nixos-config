{pkgs, ...}: {
  config = {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;
    };
  };
}
