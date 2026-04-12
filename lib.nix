{inputs, ...}: let
  myLib = (import ./lib.nix) {inherit inputs;};

  inherit (inputs.self) outputs;
in rec {
  mkSystem = config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
        myModulesPath = ./modules/nixos;
        myHomeManagerModulesPath = ./modules/home-manager;
        myConstantsModulesPath = ./modules/constants;
      };
      modules = [
        config
        ./modules/constants
      ];
    };

  mkDarwinSystem = config:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs outputs myLib;
        myModulesPath = ./modules/nix-darwin;
        myHomeManagerModulesPath = ./modules/home-manager;
        myConstantsModulesPath = ./modules/constants;
      };
      modules = [
        config
        ./modules/constants
      ];
    };

  filesIn = dir: (map (fname: dir + "/${fname}")
    (builtins.attrNames (builtins.readDir dir)));

  forAllSystems = let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    inputs.nixpkgs.lib.genAttrs systems;

  pkgsForAllSystems = f:
    forAllSystems (system: let
      parsedSystem = inputs.nixpkgs.lib.systems.parse.mkSystemFromString system;
      isDarwin = inputs.nixpkgs.lib.systems.inspect.predicates.isDarwin parsedSystem;
      nixpkgs =
        if isDarwin
        then inputs.nixpkgs-darwin
        else inputs.nixpkgs;
    in
      f {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      });
}
