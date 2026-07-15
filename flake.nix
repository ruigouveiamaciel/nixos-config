{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        jupiter = mkSystem ./hosts/jupiter;
        saturn = mkSystem ./hosts/saturn;
        kde-install-iso = mkSystem ./hosts/kde-install-iso;
      };

      darwinConfigurations = {
        work-macbook = mkDarwinSystem ./hosts/macbook;
      };

      packages = pkgsForAllSystems ({pkgs, ...}: (import ./packages {
        inherit inputs pkgs;
      }));

      formatter = pkgsForAllSystems ({pkgs, ...}: pkgs.alejandra);

      overlays = import ./overlays {inherit inputs;};
    };
}
