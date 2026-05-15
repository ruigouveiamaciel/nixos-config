{
  programs.fish.shellAbbrs = {
    "rebuild" = "cd ~/projects/nixos-config && sudo nixos-rebuild switch --log-format internal-json --flake .#saturn &| nom --json";
    "build" = "cd ~/projects/nixos-config && sudo nixos-rebuild build --log-format internal-json --flake .#saturn &| nom --json";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
    "no" = "cd ~/projects/nixos-config && nvim .";
  };

  home.stateVersion = "24.11";
}
