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
        proxmox-devbox = mkSystem ./hosts/proxmox/devbox-lxc;
        proxmox-unifi = mkSystem ./hosts/proxmox/unifi-lxc;
        proxmox-qbittorrent = mkSystem ./hosts/proxmox/qbittorrent-lxc;
        proxmox-flood = mkSystem ./hosts/proxmox/flood-lxc;
        proxmox-vikunja = mkSystem ./hosts/proxmox/vikunja-lxc;
        proxmox-paperless = mkSystem ./hosts/proxmox/paperless-lxc;
        proxmox-homepage = mkSystem ./hosts/proxmox/homepage-lxc;
        proxmox-radarr = mkSystem ./hosts/proxmox/radarr-lxc;
        proxmox-sonarr = mkSystem ./hosts/proxmox/sonarr-lxc;
        proxmox-bazarr = mkSystem ./hosts/proxmox/bazarr-lxc;
        proxmox-prowlarr = mkSystem ./hosts/proxmox/prowlarr-lxc;
        proxmox-jellyseerr = mkSystem ./hosts/proxmox/jellyseerr-lxc;
        proxmox-jellyfin = mkSystem ./hosts/proxmox/jellyfin-lxc;
        proxmox-immich = mkSystem ./hosts/proxmox/immich-lxc;
        proxmox-home-assistant = mkSystem ./hosts/proxmox/home-assistant-lxc;
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
            hostname = "10.0.102.253";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-unifi;
          };
          qbittorrent = {
            hostname = "10.0.102.3";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-qbittorrent;
          };
          flood = {
            hostname = "10.0.102.4";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-flood;
          };
          homepage = {
            hostname = "10.0.102.254";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-homepage;
          };
          vikunja = {
            hostname = "10.0.102.11";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-vikunja;
          };
          paperless = {
            hostname = "10.0.102.10";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-paperless;
          };
          radarr = {
            hostname = "10.0.102.5";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-radarr;
          };
          sonarr = {
            hostname = "10.0.102.6";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-sonarr;
          };
          bazarr = {
            hostname = "10.0.102.7";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-bazarr;
          };
          prowlarr = {
            hostname = "10.0.102.8";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-prowlarr;
          };
          jellyseerr = {
            hostname = "10.0.102.9";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-jellyseerr;
          };
          jellyfin = {
            hostname = "10.0.102.12";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-jellyfin;
          };
          immich = {
            hostname = "10.0.102.13";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-immich;
          };
          home-assistant = {
            hostname = "10.0.102.14";
            profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.proxmox-home-assistant;
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
