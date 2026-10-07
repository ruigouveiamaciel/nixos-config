{
  pkgs,
  lib,
  options,
  ...
}: let
  neovimPackage = pkgs.myPackages.neovim;
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
                directory = ".cache/nvf";
                mode = "0700";
              }
              {
                directory = ".local/share/nvf";
                mode = "0700";
              }
              {
                directory = ".local/state/nvf";
                mode = "0700";
              }
            ];
          };
        };
      }
    ));
}
