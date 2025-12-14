{
  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#saturn";
    "build" = "cd /persist/nixos-config && sudo nixos-rebuild build --flake .#saturn &| nom";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
    "no" = "cd /persist/nixos-config && nvim .";
  };
}
