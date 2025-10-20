{pkgs, ...}: let
  neovimPackage = pkgs.myNeovim;
in {
  home.packages = [neovimPackage];

  programs = {
    bash.initExtra = ''
      export EDITOR=${neovimPackage}
    '';
    fish.shellInit = ''
      export EDITOR=${neovimPackage}
    '';
    zsh.initExtra = ''
      export EDITOR=${neovimPackage}
    '';
  };
}
