{
  inputs,
  outputs,
  myLib,
  myHomeManagerModulesPath,
  myConstantsModulesPath,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
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
