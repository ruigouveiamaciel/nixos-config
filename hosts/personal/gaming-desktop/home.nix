{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#personal-gaming-desktop";
    "build" = "cd /persist/nixos-config && sudo nixos-rebuild build --flake .#personal-gaming-desktop &| nom";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
  };
}
