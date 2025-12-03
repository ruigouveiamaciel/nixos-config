{
  inputs,
  outputs,
  myLib,
  myHomeManagerModulesPath,
  myConstantsModulesPath,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs outputs myLib;
      myModulesPath = myHomeManagerModulesPath;
    };
    sharedModules = [
      "${myConstantsModulesPath}"
    ];
  };
}
