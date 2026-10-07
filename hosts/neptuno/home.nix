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

  programs.plasma.powerdevil = {
    AC = {
      powerButtonAction = lib.mkForce "nothing";
      powerProfile = lib.mkDefault "performance";
    };
    battery = {
      powerButtonAction = lib.mkForce "nothing";
      powerProfile = lib.mkDefault "powerSaving";
    };
    lowBattery = {
      powerButtonAction = lib.mkForce "nothing";
      powerProfile = lib.mkDefault "powerSaving";
    };
  };

  home.stateVersion = "26.05";
}
