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

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        proxmox-devbox = mkSystem ./hosts/proxmox/devbox;
        proxmox-unifi = mkSystem ./hosts/proxmox/unifi;
        proxmox-storagebox = mkSystem ./hosts/proxmox/storagebox;
        proxmox-jellyfin = mkSystem ./hosts/proxmox/jellyfin;
        proxmox-qbittorrent = mkSystem ./hosts/proxmox/qbittorrent;
        proxmox-media-management = mkSystem ./hosts/proxmox/media-management;
        proxmox-homepage = mkSystem ./hosts/proxmox/homepage;
        proxmox-minimal-vm = mkSystem ./hosts/proxmox/minimal-vm;
        proxmox-minimal-iso = mkSystem ./hosts/proxmox/minimal-iso;
        proxmox-minimal-lxc = mkSystem ./hosts/proxmox/minimal-lxc;
      };

      darwinConfigurations = {
        darwin-work = mkDarwinSystem ./hosts/darwin/work;
      };

      deploy = {
        user = "root";
        sshUser = "root";
        sshOpts = [];
        fastConnection = true;
        autoRollback = true;
        magicRollback = false;
        interactiveSudo = false;
        remoteBuild = false;
        nodes = {
          unifi = {
            hostname = "10.0.0.30";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-unifi;
          };
          storagebox = {
            hostname = "10.0.102.3";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-storagebox;
          };
          jellyfin = {
            hostname = "10.0.102.4";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-jellyfin;
          };
          qbittorrent = {
            hostname = "10.0.102.5";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-qbittorrent;
          };
          media-management = {
            hostname = "10.0.102.16";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-media-management;
          };
          homepage = {
            hostname = "10.0.102.254";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-homepage;
          };
        };
      };

      checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
      nixosModules.default = ./modules/nixos;
      homeManagerModules.default = ./modules/home-manager;
      darwinModules.default = ./modules/darwin;
      packages = pkgsForAllSystems ({pkgs, ...}: import ./packages {inherit pkgs inputs;});
      formatter = pkgsForAllSystems ({pkgs, ...}: pkgs.alejandra);
      overlays = import ./overlays {inherit inputs;};
    };
}
