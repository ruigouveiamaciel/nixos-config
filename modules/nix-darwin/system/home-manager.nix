{
  inputs,
  outputs,
  myLib,
  myHomeManagerModulesPath,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs outputs myLib;
      myModulesPath = myHomeManagerModulesPath;
    };
    sharedModules = [
      outputs.darwinModules.constants
    ];
  };
}
