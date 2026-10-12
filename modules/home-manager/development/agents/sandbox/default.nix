{
  osConfig,
  myLib,
  ...
}: let
  host = osConfig.networking.hostName;

  sandbox-system =
    myLib.mkSystem
    {
      imports = [./system.nix];
      networking.hostName = "${host}-sandbox";
    };

  run-sandbox-vm = sandbox-system.config.system.build.vm;
in {
  home.packages = [
    run-sandbox-vm
  ];
}
