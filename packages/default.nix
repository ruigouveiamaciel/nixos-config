{
  inputs,
  pkgs,
  ...
} @ args: {
  # example = pkgs.callPackage ./example { };

  myNeovim =
    (inputs.nvf.lib.neovimConfiguration
      {
        inherit pkgs;
        modules = [
          ./neovim.nix
        ];
      }).neovim;

  iosevka-kitty = import ./iosevka-kitty.nix args;
}
