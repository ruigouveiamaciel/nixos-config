{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      ranger
      neofetch
      eza
      ripgrep
      jq
      zip
      unzip
      htop
      curl
      wget
    ];
  };
}
