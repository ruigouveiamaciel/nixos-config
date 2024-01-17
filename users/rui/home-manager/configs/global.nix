{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.nix-colors.homeManagerModules.default

      ../features/cli
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;

    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "rui";
    homeDirectory = "/home/rui";
    persistence."/nix/persist${config.home.homeDirectory}" = {
      allowOther = lib.mkDefault true;
      directories = [
        ".local/share/nix"
        ".cache"
      ];
    };
    persistence."/nix/backup${config.home.homeDirectory}" = {
      allowOther = lib.mkDefault true;
    };
  };

  # Color scheme
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # Global packages
  home.packages = with pkgs; [
    eza
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
