{
  pkgs,
  lib,
  options,
  ...
}: let
  neovimPackage = pkgs.myNeovim;
in {
  config = lib.mkMerge ([
      {
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
    ]
    ++ (
      lib.optional (options.home ? "persistence")
      {
        home.persistence = {
          "/persist" = {
            directories = [
              {
                directory = ".local/share/nvf/site/spell";
                mode = "0700";
              }
            ];
          };
        };
      }
    ));
}
