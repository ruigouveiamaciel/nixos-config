{pkgs, ...}: let
  neovimPackage = pkgs.myNeovim;
in {
  home.packages = [neovimPackage];

  programs = {
    bash.initExtra = ''
      export EDITOR=nvim
    '';
    fish.shellInit = ''
      export EDITOR=nvim
    '';
    zsh.initExtra = ''
      export EDITOR=nvim
    '';
  };
}
