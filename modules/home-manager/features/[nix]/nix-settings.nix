{outputs, ...}: {
  config = {
    programs = {
      home-manager.enable = true;
      command-not-found.enable = false;
    };

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config.allowUnfree = true;
    };
  };
}
