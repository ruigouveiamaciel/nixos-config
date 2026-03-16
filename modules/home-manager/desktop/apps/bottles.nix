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
          (bottles.override
            {
              removeWarningPopup = true;
            })
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      persistence."/persist" = {
        directories = [
          ".local/share/bottles"
        ];
      };
    })
  );
}
