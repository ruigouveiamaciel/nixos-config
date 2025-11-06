{
  inputs,
  pkgs,
  ...
}: {
  # example = pkgs.callPackage ./example { };

  myOpencode = pkgs.callPackage ./opencode.nix {};

  myNeovim =
    (inputs.nvf.lib.neovimConfiguration
      {
        inherit pkgs;
        modules = [
          ./neovim.nix
        ];
      }).neovim;
}
