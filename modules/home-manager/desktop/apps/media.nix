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
            vlc
            rawtherapee
            hdrmerge
          ];

          file.".config/RawTherapee/clutsdir".source = pkgs.fetchzip {
            url = "http://rawtherapee.com/shared/HaldCLUT.zip";
            sha256 = "sha256-OtsHpOKrZImvWnKCTqewyo2xjYg7dwpqxdXLVutfhzw=";
          };
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".config/RawTherapee";
            mode = "0700";
          }
        ];
      };
    })
  );
}
