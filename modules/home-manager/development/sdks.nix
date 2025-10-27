{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    alejandra
    lua
    stylua
    unstable.go
    nodejs_20
    pnpm_10
  ];
}
