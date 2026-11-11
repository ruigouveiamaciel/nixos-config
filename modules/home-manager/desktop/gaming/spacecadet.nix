{
  pkgs,
  options,
  lib,
  ...
}: {
  home = lib.mkMerge [
    {
      packages = [
        # Native port of the decompiled Windows 3D Pinball (Space Cadet) from XP
        pkgs.space-cadet-pinball
      ];
    }
    # Persist high scores / settings (stored via SDL pref path) across rebuilds
    (lib.optionalAttrs (options.home ? "persistence") {
      persistence."/persist".directories = [
        ".local/share/SpaceCadetPinball"
      ];
    })
  ];
}
