{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home = {
          packages = with pkgs; [
            imagemagick
            vlc
            unstable.grayjay
            picard
            ffmpeg
            audacity
            obs-studio
          ];
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".local/share/Grayjay";
            mode = "0700";
          }
        ];
      };
    })
  );
}
