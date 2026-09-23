{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    ripgrep
    fzf
    fd
    tree
  ];

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
