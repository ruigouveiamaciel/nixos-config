{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/desktop/apps"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#personal-gaming-desktop";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
  };
}
