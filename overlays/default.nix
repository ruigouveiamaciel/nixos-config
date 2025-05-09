{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  additions = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = final;
    };

  # Make nixos-unstable accessible through 'pkgs.unstable'
  nixos-unstable-packages = final: _prev: {
    unstable = import inputs.nixos-unstable {
      inherit (final) system config;
    };
  };

  nixpkgs-unstable-packages = final: _prev: {
    nixpkgs-unstable = import inputs.nixpkgs-unstable {
      inherit (final) system config;
    };
  };
}
