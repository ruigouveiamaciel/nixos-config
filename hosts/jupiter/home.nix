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
    "root-diff" = "sudo zfs diff zroot/encrypted/root@blank | nvim";
  };

  programs.plasma.powerdevil.AC.autoSuspend = {
    action = lib.mkForce "nothing";
    idleTimeout = lib.mkForce null;
  };

  home.stateVersion = "24.11";
}
