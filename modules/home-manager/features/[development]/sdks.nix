{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      gcc
      alejandra
      lua
      stylua
      go
      nodejs_20
      pnpm_10
    ];
  };
}
