{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        programs.anki = {
          enable = true;
          reduceMotion = true;
          profiles = {
            smokewow = {
              default = true;
            };
          };
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          {
            directory = ".cache/Anki";
            mode = "0700";
          }
          {
            directory = ".local/share/Anki2";
            mode = "0700";
          }
        ];
      };
    })
  );
}
