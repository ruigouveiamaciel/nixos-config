{
  inputs,
  outputs,
  myLib,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  config = {
    home-manager = {
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs outputs myLib;
      };
    };
  };
}
