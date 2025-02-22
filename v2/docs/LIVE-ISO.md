nix build .#nixosConfigurations.minimal-live-iso.config.system.build.isoImage --extra-experimental-features "nix-command flakes"
