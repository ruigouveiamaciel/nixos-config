{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  packages = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = import inputs.nixpkgs-packages {
        inherit (final) system config;
      };
    };

  # Make inputs.nixos-unstable accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system config;
    };
  };

  nur = inputs.nur.overlays.default;
}
