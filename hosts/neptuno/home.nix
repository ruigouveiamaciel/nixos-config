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
    "rebuild" = "cd ~/projects/nixos-config && sudo nixos-rebuild switch --log-format internal-json -v --flake .#neptuno &| nom --json";
    "build" = "cd ~/projects/nixos-config && nixos-rebuild build --log-format internal-json -v --flake .#neptuno &| nom --json";
    "root-diff" = "sudo find / -xdev | nvim";
  };

  # Disable power button as it easy to accidently press during transport
  programs.plasma.powerdevil = let
    action = "nothing";
  in {
    AC = lib.mkForce action;
    battery.powerButtonAction = lib.mkForce action;
    lowBattery = lib.mkForce action;
  };

  home.stateVersion = "26.05";
}
