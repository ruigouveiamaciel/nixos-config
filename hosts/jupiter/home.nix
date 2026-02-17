{
  myModulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${myModulesPath}/desktop/apps"
    "${myModulesPath}/desktop/plasma-settings.nix"
  ];

  home.packages = [pkgs.google-chrome];

  programs.fish.shellAbbrs = {
    "rebuild" = "cd /persist/nixos-config && sudo nixos-rebuild switch --flake .#jupiter";
    "build" = "cd /persist/nixos-config && sudo nixos-rebuild build --log-format json-internal -v --flake .#jupiter &| nom --json";
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank";
    "no" = "cd /persist/nixos-config && nvim .";
  };
}
