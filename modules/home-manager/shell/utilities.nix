{pkgs, ...}: {
  home.packages = with pkgs; [
    unrar
    eza # better ls
    ripgrep # better grep
    zip
    unzip
    htop # Process viewer
    curl
    wget
    jq # JSON formatting and manipulation
    jless # JSON viewer
    fzf # Fuzzy find files
    bc # Calculator
    zoxide # Smarter cd
  ];
}
