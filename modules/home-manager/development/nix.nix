{pkgs, ...}: {
  home.packages = with pkgs; [deploy-rs nixos-anywhere];
  programs.nix-index.enable = true;
}
