{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "ComicShannsMono Nerd Font Mono";
      package = pkgs.nerdfonts.override {fonts = ["ComicShannsMono"];};
      #family = "FiraCode Nerd Font Mono";
      #package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
    };
    regular = {
      #family = "Fira Sans";
      #package = pkgs.fira;
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
