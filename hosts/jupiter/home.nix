{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd ~/projects/nixos-config && sudo nixos-rebuild switch --log-format internal-json -v --flake .#jupiter &| nom --json";
    "build" = "cd ~/projects/nixos-config && sudo nixos-rebuild build --log-format internal-json -v --flake .#jupiter &| nom --json";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
    "no" = "cd ~/projects/nixos-config && nvim .";
  };
}
