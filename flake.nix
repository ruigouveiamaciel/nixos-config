{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-packages.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    myLib = import ./lib.nix {inherit inputs;};
  in
    with myLib; {
      nixosConfigurations = {
        personal-gaming-desktop = mkSystem ./hosts/personal/gaming-desktop;
        personal-install-iso = mkSystem ./hosts/personal/install-iso;
        # proxmox-devbox = mkSystem ./hosts/homelab/devbox-lxc;
        # proxmox-unifi = mkSystem ./hosts/homelab/unifi-lxc;
        # proxmox-qbittorrent = mkSystem ./hosts/homelab/qbittorrent-lxc;
        # proxmox-flood = mkSystem ./hosts/homelab/flood-lxc;
        # proxmox-vikunja = mkSystem ./hosts/homelab/vikunja-lxc;
        # proxmox-paperless = mkSystem ./hosts/homelab/paperless-lxc;
        # proxmox-homepage = mkSystem ./hosts/homelab/homepage-lxc;
        # proxmox-radarr = mkSystem ./hosts/homelab/radarr-lxc;
        # proxmox-sonarr = mkSystem ./hosts/homelab/sonarr-lxc;
        # proxmox-bazarr = mkSystem ./hosts/homelab/bazarr-lxc;
        # proxmox-prowlarr = mkSystem ./hosts/homelab/prowlarr-lxc;
        # proxmox-jellyseerr = mkSystem ./hosts/homelab/jellyseerr-lxc;
        # proxmox-jellyfin = mkSystem ./hosts/homelab/jellyfin-lxc;
        # proxmox-immich = mkSystem ./hosts/homelab/immich-lxc;
        # proxmox-home-assistant = mkSystem ./hosts/homelab/home-assistant-lxc;
        # proxmox-minimal-vm = mkSystem ./hosts/homelab/minimal-vm;
        # proxmox-minimal-iso = mkSystem ./hosts/homelab/minimal-iso;
        # proxmox-minimal-lxc = mkSystem ./hosts/homelab/minimal-lxc;
      };

      darwinConfigurations = {
        work-macbook = mkDarwinSystem ./hosts/work/macbook;
      };

      nixosModules = {
        constants = ./modules/constants;
      };

      homeManagerModules = {
        constants = ./modules/constants;
      };

      darwinModules = {
        constants = ./modules/constants;
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
