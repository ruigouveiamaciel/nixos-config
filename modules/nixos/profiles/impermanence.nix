{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = lib.mkIf (builtins.hasAttr "home-manager" config) {
    home-manager.sharedModules = [
      {
        imports = [
          inputs.impermanence.homeManagerModules.impermanence
        ];
      }
    ];
  };
}
