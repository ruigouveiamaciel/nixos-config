{
  pkgs,
  lib,
  options,
  ...
}: {
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
