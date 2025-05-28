{
  inputs,
  pkgs,
  ...
}:
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    ./config.nix
  ];
})
.neovim
