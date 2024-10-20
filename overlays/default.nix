{inputs, ...}: {
  # Bring the custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final;

  # Change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # Make nixos-unstable accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config = final.config;
    };
  };

  discord-replace = final: _prev: {
    discord =
      (import inputs.discord-nixpkgs
        {
          system = final.system;
          config = final.config;
        })
      .discord;
  };
}
