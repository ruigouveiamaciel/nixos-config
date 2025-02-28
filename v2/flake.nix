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

    deploy-rs.url = "github:serokell/deploy-rs";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        proxmox-devbox = mkSystem ./hosts/proxmox/devbox;
        proxmox-devbox-lxc = mkSystem ./hosts/proxmox/devbox-lxc;
        proxmox-unifi = mkSystem ./hosts/proxmox/unifi;
        proxmox-minimal-virtual-machine = mkSystem ./hosts/proxmox/minimal-virtual-machine;
        proxmox-minimal-live-iso = mkSystem ./hosts/proxmox/minimal-live-iso;
        proxmox-minimal-lxc = mkSystem ./hosts/proxmox/minimal-lxc;
      };

      deploy = {
        user = "root";
        sshUser = "root";
        sshOpts = [];
        fastConnection = true;
        autoRollback = true;
        magicRollback = true;
        interactiveSudo = false;
        remoteBuild = false;
        nodes = {
          devbox = {
            hostname = "devbox";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-devbox-lxc;
          };
          unifi = {
            hostname = "10.0.0.29";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-unifi;
          };
        };
      };

      checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
      nixosModules.default = ./modules/nixos;
      homeManagerModules.default = ./modules/home-manager;
      packages = pkgsForAllSystems ({pkgs, ...}: import ./packages {inherit pkgs inputs;});
      formatter = pkgsForAllSystems ({pkgs, ...}: pkgs.alejandra);
      overlays = import ./overlays {inherit inputs;};
    };
}
