{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-packages.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence/home-manager-v2"; # Branch with fixes for the latest issues
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-packages";
    };
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        personal-gaming-desktop = mkSystem ./hosts/personal/gaming-desktop;
        personal-install-iso = mkSystem ./hosts/personal/install-iso;
      };

      darwinConfigurations = {
        work-macbook = mkDarwinSystem ./hosts/work/macbook;
      };

      packages = pkgsForAllSystems ({system, ...}: (import ./packages {
        inherit inputs;
        pkgs = import inputs.nixpkgs-packages {
          inherit system;
        };
      }));

      formatter = pkgsForAllSystems ({pkgs, ...}: pkgs.alejandra);

      overlays = import ./overlays {inherit inputs;};
    };
}
