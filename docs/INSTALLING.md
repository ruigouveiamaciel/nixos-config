# Installing a NixOS host

Boot the install ISO first → see [LIVE-ISO.md](LIVE-ISO.md).

## 1. Clone the config on the live ISO

```bash
git clone https://git.iuseneovim.fyi/smokewow/nixos-config.git
cd nixos-config
```

## 2. Partition, format and mount

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount --flake .#<hostname>
```

- encrypted hosts will prompt for the passphrase.
- Everything ends up mounted under `/mnt` (root, `/nix`, `/persist`, `/boot`).

## 3. Install

```bash
sudo nixos-install --no-root-passwd --flake .#<hostname>
```

## 4. Reboot

```bash
reboot
```
