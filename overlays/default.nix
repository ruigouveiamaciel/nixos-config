{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  additions = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = final;
    };

  # Make nixos-unstable accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system config;
    };
  };
}
