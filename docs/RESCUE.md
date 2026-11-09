# Debugging NixOS from the live ISO

Boot the KDE install ISO → see [LIVE-ISO.md](LIVE-ISO.md). Then:

```bash
sudo -i
lsblk -f    # identify your disks
```

Pick your host's filesystem: **zfs**, **btrfs** or other. Both end with mounting
everything under `/mnt` and entering with `nixos-enter`.

## ZFS hosts

### 1. Import the pool, load keys, mount everything

`-N` lets you load keys before anything mounts; legacy mountpoints need explicit
mounts.

```bash
zpool import -f -N zroot  # adjust pool accordingly
zfs load-key -a           # prompts for the passphrase
zfs mount -a
```

If the pool was not exported cleanly:

```bash
zpool import -f -N -o cachefile=none zroot
zpool status
```

### 2. Mount /boot

```bash
ls /dev/disk/by-partlabel                 
mount /dev/disk/by-partlabel/nixos-boot /mnt/boot  # adjust label accordingly
```

### 3. Enter the system

```bash
nixos-enter --root /mnt
```

---

## Btrfs hosts

### 1. Unlock and mount

```bash
cryptsetup luksOpen /dev/disk/by-id/nvme-WD_BLACK_SN770M_500GB_26025T800272 cryptroot

mount -o compress=zstd,noatime,subvol=root     /dev/mapper/cryptroot /mnt
mount -o compress=zstd,noatime,subvol=nix      /dev/mapper/cryptroot /mnt/nix
mount -o compress=zstd,noatime,subvol=persist  /dev/mapper/cryptroot /mnt/persist

mount /dev/disk/by-partlabel/nixos-boot /mnt/boot  # adjust label accordingly
```

### 2. If `/root` is broken, roll it back to a blank state manually

```bash
umount /mnt/nix /mnt/persist /mnt/boot
umount /mnt
mount /dev/mapper/cryptroot /mnt
btrfs subvolume delete /mnt/root
btrfs subvolume snapshot /mnt/root-blank /mnt/root
umount /mnt
# then redo step 1 to remount everything and continue
```

## Read the host's journal from the live ISO

```bash
journalctl -D /mnt/persist/var/log
journalctl -D /mnt/persist/var/log -b -1        # previous boot
```
