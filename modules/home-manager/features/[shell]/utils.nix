{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      eza
      ripgrep
      zip
      unzip
      htop
      curl
      wget
      jq
      jless
      fzf
      fd
      bc # Calculator in terminal
    ];
  };
}
