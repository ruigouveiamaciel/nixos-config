{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer
      gcc
      alejandra
      lua
      stylua
    ];
  };
}
