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
        proxmox-media-server = mkSystem ./hosts/proxmox/media-server;
        proxmox-qbittorrent = mkSystem ./hosts/proxmox/qbittorrent;
        proxmox-media-management = mkSystem ./hosts/proxmox/media-management;
        proxmox-vikunja = mkSystem ./hosts/proxmox/vikunja;
        proxmox-paperless = mkSystem ./hosts/proxmox/paperless;
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
        autoRollback = false;
        magicRollback = false;
        interactiveSudo = false;
        remoteBuild = false;
        nodes = {
          unifi = {
            hostname = inputs.self.nixosConfigurations.proxmox-unifi.config.myNixOS.services.discovery.default.unifi.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-unifi;
          };
          storagebox = {
            hostname = inputs.self.nixosConfigurations.proxmox-storagebox.config.myNixOS.services.discovery.default.nfs.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-storagebox;
          };
          media-server = {
            hostname = inputs.self.nixosConfigurations.proxmox-media-server.config.myNixOS.services.discovery.default.media-server.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-media-server;
          };
          qbittorrent = {
            hostname = inputs.self.nixosConfigurations.proxmox-qbittorrent.config.myNixOS.services.discovery.default.qbittorrent.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-qbittorrent;
          };
          media-management = {
            hostname = inputs.self.nixosConfigurations.proxmox-media-management.config.myNixOS.services.discovery.default.media-management.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-media-management;
          };
          homepage = {
            hostname = inputs.self.nixosConfigurations.proxmox-homepage.config.myNixOS.services.discovery.default.homepage.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-homepage;
          };
          vikunja = {
            hostname = inputs.self.nixosConfigurations.proxmox-vikunja.config.myNixOS.services.discovery.default.vikunja.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-vikunja;
          };
          paperless = {
            hostname = inputs.self.nixosConfigurations.proxmox-paperless.config.myNixOS.services.discovery.default.paperless.ip;
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-paperless;
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
