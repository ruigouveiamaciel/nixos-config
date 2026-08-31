{pkgs, ...}: {
  imports = [
    ./compression.nix
    ./file-navigation.nix
    ./network.nix
    ./system-monitoring.nix
  ];

  home.packages = with pkgs; [
    parallel
  ];
}
