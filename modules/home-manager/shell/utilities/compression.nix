{pkgs, ...}: {
  home.packages = with pkgs; [
    unrar
    zip
    unzip
  ];
}
