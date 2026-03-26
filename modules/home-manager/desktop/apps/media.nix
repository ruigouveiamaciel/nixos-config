{
  pkgs,
  lib,
  options,
  ...
}: let
  haldclut = pkgs.fetchzip {
    url = "http://rawtherapee.com/shared/HaldCLUT.zip";
    sha256 = "sha256-OtsHpOKrZImvWnKCTqewyo2xjYg7dwpqxdXLVutfhzw=";
  };
in {
  home = lib.mkMerge (
    [
      {
        packages = with pkgs; [
          vlc
          aonsoku
          spotify
          rawtherapee
          hdrmerge
        ];
      }
      {
        file.".config/RawTherapee/clutsdir".source = haldclut;
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      persistence."/persist" = {
        directories = [
          ".config/spotify"
          ".config/RawTherapee"
          ".local/share/com.victoralvesf.aonsoku"
        ];
      };
    })
  );
}
