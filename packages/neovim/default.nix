{
  inputs,
  pkgs,
  ...
}:
(inputs.nvf.lib.neovimConfiguration {
  pkgs = pkgs.nixpkgs-unstable;
  modules = [
    ./config.nix
  ];
})
.neovim
