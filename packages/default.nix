{
  inputs,
  pkgs,
  ...
}: {
  # example = pkgs.callPackage ./example { };

  myNeovim =
    (inputs.nvf.lib.neovimConfiguration
      {
        inherit pkgs;
        modules = [
          ./neovim.nix
        ];
      }).neovim;
}
