{
  inputs,
  outputs,
  myLib,
  myHomeManagerModulesPath,
  myConstantsModulesPath,
  pkgs,
  ...
}: let
  home-manager-input =
    if pkgs.stdenv.isDarwin
    then inputs.home-manager-darwin
    else inputs.home-manager;
in {
  imports = [
    home-manager-input.nixosModules.home-manager
  ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs outputs myLib;
      myModulesPath = myHomeManagerModulesPath;
    };
    sharedModules = [
      "${myConstantsModulesPath}"
    ];
  };
}
