{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  additions = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = final;
    };

  # Change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # Make nixos-unstable accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system config;
    };
  };
}
