{
  inputs,
  outputs,
  myLib,
  myHomeManagerModulesPath,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs outputs myLib;
      myModulesPath = myHomeManagerModulesPath;
    };
    sharedModules = [
      outputs.nixosModules.constants
    ];
  };
}
