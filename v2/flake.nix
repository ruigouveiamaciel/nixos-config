{
  description = "Rui's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        minimal-live-iso = mkSystem ./hosts/live-iso/minimal/configuration.nix;
        devbox = mkSystem ./hosts/virtual-machine/devbox/configuration.nix;
      };

      homeConfigurations = {
        "rui@minimal-live-iso" = mkHome "x86_64-linux" ./hosts/live-iso/minimal/home.nix;
      };

      nixosModules.default = ./modules/nixos;
      homeManagerModules.default = ./modules/home-manager;

      packages =
        pkgsForAllSystems ({pkgs, ...}:
          import ./packages {inherit pkgs inputs;});

      formatter = pkgsForAllSystems ({pkgs, ...}: pkgs.alejandra);

      overlays = import ./overlays {inherit inputs;};
    };
}
