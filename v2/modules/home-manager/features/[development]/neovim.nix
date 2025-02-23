{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [myNeovim];

    programs = let
      nvim = "${pkgs.myNeovim}/bin/nvim";
    in {
      bash.initExtra = ''
        export EDITOR=${nvim}
      '';
      fish.shellInit = ''
        export EDITOR=${nvim}
      '';
      zsh.initExtra = ''
        export EDITOR=${nvim}
      '';
    };
  };
}
