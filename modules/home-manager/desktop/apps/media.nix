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
            # Davinci Resolve Photo - still doesn't support .ORF raws
            # unstable.davinci-resolve
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
