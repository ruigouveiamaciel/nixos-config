{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd ~/projects/nixos-config && sudo nixos-rebuild switch --log-format internal-json -v --flake .#neptuno &| nom --json";
    "build" = "cd ~/projects/nixos-config && nixos-rebuild build --log-format internal-json -v --flake .#neptuno &| nom --json";
    "root-diff" = "sudo find / -xdev | nvim";
  };

  home.stateVersion = "26.05";
}
