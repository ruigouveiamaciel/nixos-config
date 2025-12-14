{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/base.nix"
    "${myModulesPath}/users/ruimaciel"

    ./homebrew.nix
    ./aerospace.nix
  ];

  home-manager.users.ruimaciel = {
    imports = [./home.nix];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
