{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      ranger
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
    ];
  };
}
