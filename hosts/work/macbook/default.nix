{myModulesPath, ...}: {
  imports = [
    "${myModulesPath}/profiles/minimal.nix"
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
