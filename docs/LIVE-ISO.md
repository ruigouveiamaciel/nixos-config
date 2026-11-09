# KDE install ISO

The ISO host is `kde-install-iso` (boots as `pluto`): Plasma 6, user `smokewow`
(auto-login), sshd on, zfs supported.

## Build

```bash
nix build .#nixosConfigurations.kde-install-iso.config.system.build.isoImage
# → result/iso/*.iso
```

## Flash to USB (replace `sdX`)

```bash
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M oflag=direct status=progress conv=fsync
```

## SSH into the live system

```bash
ssh smokewow@<iso-ip>
```

Then continue with [INSTALLING.md](INSTALLING.md) or [RESCUE.md](RESCUE.md).
