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
      inputs.nix-colors.homeManagerModules.default
      inputs.nur.hmModules.nur

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
  };

  # Color scheme
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # Global packages
  home.packages = with pkgs; [
    eza
    ripgrep
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
