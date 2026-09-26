```bash
nix build .#nixosConfigurations.kde-install-iso.config.system.build.isoImage --extra-experimental-features "nix-command flakes"
```
