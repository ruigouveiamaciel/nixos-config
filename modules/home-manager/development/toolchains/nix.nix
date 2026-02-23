{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    nix-output-monitor
  ];
}
