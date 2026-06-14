{
  myModulesPath,
  lib,
  options,
  ...
}: {
  imports = [
    "${myModulesPath}/profiles/essentials.nix"
    "${myModulesPath}/profiles/development.nix"
    "${myModulesPath}/shell/starship.nix"
  ];

  config = lib.mkMerge ([
      {
        home.file.".config/Yubico/u2f_keys" = {
          text = "smokewow:yOfkk9QbzaNDg3n6Lux6ABf3TInBsYZbQGB4xppSCLcqSdjQd50g0mo9SF0IzIP4W5SeO6uEtGB6BhL4VJudoA==,5KyMc25ucTNc0ThSGV65Wnjc44/Qot4E9uWsPOxZn5FOgSY+N7UssdSjuouMeaCvJlaVViFHkQQr86zLusui4Q==,es256,+presence:7drgB8HsXY69tyBEslOoUebIovVyE4+5N4Uv5qaqlvJgLZalhG2xOEx51ViD7vTjgZ/sNy75VaD5SXMS3A2h0w==,aQmGbVjkaYM+zv5z8ptrooiBlp6soW0RsMsDAZAVTs/H9r3QSEP7gCyhiGA/ToRON0vbdKr8J8BJftnMMONt/A==,es256,+presence:8OIBpSDDDUJl4wDCoJ4AROUF/90nTEoWkLpfqDsF9vHr3tgBS2W6zn2Z+kDxYvum7qo149u0OEIc1HRwzM7D3Q==,YaCgpccp/fty/ctPZ91g7nS0UXTrlmLKrK6d0HnCoVJ5hfy1ympOxvrP1SaRA/YnS0hsDjAikkPCrDJr5cxySQ==,es256,+presence";
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
                directory = "projects";
                mode = "700";
              }
              {
                directory = "repositories";
                mode = "700";
              }
            ];
          };
        };
      }
    ));
}
