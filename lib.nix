{inputs, ...}: let
  myLib = (import ./lib.nix) {inherit inputs;};

  inherit (inputs.self) outputs;
in rec {
  # ======================= Package Helpers ======================== #

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

  pkgsForAllSystems = f:
    forAllSystems (system:
      f {
        inherit system;
        pkgs = pkgsFor system;
      });

  # ========================== Buildables ========================== #

  mkSystem = config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
        myModulesPath = ./modules/nixos;
        myHomeManagerModulesPath = ./modules/home-manager;
      };
      modules = [
        config
        outputs.nixosModules.default
        outputs.nixosModules.constants
      ];
    };

  mkDarwinSystem = config:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs outputs myLib;
        myModulesPath = ./modules/nix-darwin;
        myHomeManagerModulesPath = ./modules/home-manager;
      };
      modules = [
        config
        outputs.darwinModules.default
        outputs.darwinModules.constants
      ];
    };

  # =========================== Helpers ============================ #

  filesIn = dir: (map (fname: dir + "/${fname}")
    (builtins.attrNames (builtins.readDir dir)));

  # ============================ Shell ============================= #

  forAllSystems = let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    inputs.nixpkgs.lib.genAttrs systems;
}
