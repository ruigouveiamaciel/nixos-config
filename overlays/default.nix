{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  myPackages = final: _prev: {
    myPackages = import ../packages {
      inherit inputs;
      pkgs = import inputs.nixpkgs-unstable {
        inherit (final) config;
        inherit (final.stdenv.hostPlatform) system;
      };
    };
  };

  # Make inputs.nixos-unstable accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) config;
      inherit (final.stdenv.hostPlatform) system;
    };
  };
}
