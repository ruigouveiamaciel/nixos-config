{
  inputs,
  lib,
  options,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config =
    lib.mkMerge
    (
      lib.optional (builtins.hasAttr "home-manager" options)
      {
        home-manager.sharedModules = [
          {
            imports = [
              inputs.impermanence.homeManagerModules.impermanence
            ];
          }
        ];
      }
    );
}
