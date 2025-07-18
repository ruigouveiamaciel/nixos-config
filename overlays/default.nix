{inputs, ...}: {
  # Bring the custom packages from the 'packages' directory
  additions = final: _prev:
    import ../packages {
      inherit inputs;
      pkgs = import inputs.nixpkgs-unstable {
        inherit (final) system config;
      };
    };

  # Make nixos-unstable accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.nixos-unstable {
      inherit (final) system config;
    };
  };

  # HyprPanel overlay
  hyprpanel = inputs.hyprpanel.overlay;
}
