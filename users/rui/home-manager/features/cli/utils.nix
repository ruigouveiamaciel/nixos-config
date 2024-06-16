{pkgs, ...}: {
  home.packages = with pkgs; [
    ranger
    neofetch
    eza
    ripgrep
    jq
  ];
}
