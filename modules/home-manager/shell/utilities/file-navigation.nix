{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    ripgrep
    fzf
    zoxide
    fd
  ];
}
