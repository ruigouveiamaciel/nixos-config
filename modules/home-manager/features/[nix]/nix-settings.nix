{outputs, ...}: {
  config = {
    programs.home-manager.enable = true;

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config.allowUnfree = true;
    };
  };
}
