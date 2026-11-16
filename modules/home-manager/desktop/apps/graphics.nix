{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = with pkgs; [
            rawtherapee
            gimp
            krita
            inkscape
          ];

          file.".config/RawTherapee/clutsdir".source = pkgs.fetchzip {
            url = "http://rawtherapee.com/shared/HaldCLUT.zip";
            sha256 = "sha256-OtsHpOKrZImvWnKCTqewyo2xjYg7dwpqxdXLVutfhzw=";
          };
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".config/RawTherapee";
              mode = "0700";
            }
            {
              directory = ".cache/krita";
              mode = "0700";
            }
            {
              directory = ".local/share/krita";
              mode = "0700";
            }
          ];
          files = [
            {
              file = ".config/kritadisplayrc";
              parentDirectory.mode = "0700";
            }
            {
              file = ".config/kritarc";
              parentDirectory.mode = "0700";
            }
          ];
        };
      };
    }));
}
