{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    settings = {
      user = {
        email = "5m0k3w0w@proton.me";
        name = "SmOkEwOw";
      };
    };
  };
}
