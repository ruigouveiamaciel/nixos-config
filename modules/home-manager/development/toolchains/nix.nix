{pkgs, ...}: {
  home.packages = with pkgs; [
    deploy-rs
    nixos-anywhere
    alejandra
  ];
}
