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

  apple-silicon = final: prev:
    inputs.nixpkgs.lib.optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      pkgs-x86_64 = import inputs.nixpkgs-unstable {
        system = "x86_64-darwin";
        inherit (final) config;
      };
    };
}
