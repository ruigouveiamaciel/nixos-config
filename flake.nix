{
  description = "NixOS Configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # Unstable Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secret Management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Useful Hardware Configurations
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Grub themes
    grub2-themes.url = "github:vinceliuice/grub2-themes";

    # Color schemes
    nix-colors.url = "github:misterio77/nix-colors";

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # nixos-wsl
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    lib = nixpkgs.lib // home-manager.lib;

    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    inherit lib;

    # Custom packages
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # The formatter for nix files
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Overlays
    overlays = import ./overlays {inherit inputs;};

    # NixOS modules
    nixosModules = import ./modules/nixos;

    # Home manager modules
    homeManagerModules = import ./modules/home-manager;

    # I name my personal computers and servers after orbital launch systems (a
    # fancy name for rockets), satellites and probes. Here are some examples:
    #
    # Sputnik 1 - The first artificial satellite to make it safely into orbit
    # around the Earth. Launched by the Soviet Union on October 4, 1957.
    #
    # Echo 1 - The first passive communications satellite. Launched by NASA on
    # August 12, 1960.
    #
    # Venera 9 - First probe to orbit Venus and return images of its surface.
    # Launched by the Soviet Union on June 8, 1975.
    #
    # Voyager 1 - The first probe to leave the solar system. Launched by NASA
    # on September 5, 1977.
    #
    # Falcon 9 - A partially reusable two-stage-to-orbit medium-lift launch
    # vehicle designed and manufactured by SpaceX in the United States.
    #
    # Soyuz - A series of spacecraft designed for the Soviet space program by
    # the Korolev Design Bureau in the 1960s that remains in service today.
    #
    # Ariane - A series of a European heavy-lift launch vehicles designed and
    # operated by the French government space agency Centre national d'études
    # spatiales (CNES), the European Space Agency (ESA) and ArianeGroup.
    #
    # -------------------------------------------------------------------------
    #
    # To build a nixos configuration, run: 'nixos-rebuild --flake .#hostname'
    nixosConfigurations = {
      # Ariane - My gaming desktop. Runs Windows 10 and NixOS, in dual boot.
      ariane = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/configs/ariane
          ./users/rui/nixos-module.nix
        ];
      };

      shenzhou = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/configs/shenzhou
          ./users/rui/nixos-module.nix
        ];
      };
      # Soyuz - My work laptop. Only runs NixOS even though I have to use
      # a remote Windows environment for pretty much everything.
      soyuz = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/configs/soyuz
          ./users/rui/nixos-module.nix
        ];
      };

      # Sputnik - Budget server containing my personal website, a private
      # minecraft server and a few other things.
      sputnik = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/configs/sputnik
          ./users/rui/nixos-module.nix
        ];
      };
    };

    homeConfigurations = {
      "rui@ariane" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./users/rui/home-manager/configs/ariane
        ];
      };
      "rui@soyuz" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./users/rui/home-manager/configs/soyuz
        ];
      };
      "rui@sputnik" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./users/rui/home-manager/configs/sputnik
        ];
      };
      "rui@shenzhou" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./users/rui/home-manager/configs/shenzhou
        ];
      };
    };
  };
}
