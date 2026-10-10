{
  myModulesPath,
  lib,
  ...
}: {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  programs.fish.shellAbbrs = {
    "root-diff" = "sudo find / -xdev | nvim";
  };

  # Disable power button as it easy to accidently press during transport
  programs.plasma.powerdevil = let
    action = "nothing";
  in {
    AC.powerButtonAction = lib.mkForce action;
    battery.powerButtonAction = lib.mkForce action;
    lowBattery.powerButtonAction = lib.mkForce action;
  };

  home.stateVersion = "26.05";
}
