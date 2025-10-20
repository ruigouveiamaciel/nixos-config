{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  packages = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = import inputs.nixpkgs-unstable {
        inherit (final) system config;
      };
    };

  # Make inputs.nixos-unstable accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.nixos-unstable {
      inherit (final) system config;
    };
  };
}
