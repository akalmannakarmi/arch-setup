#!/usr/bin/env bash

# --- Format partitions ---
# --- Format and mount root filesystem ---
if [[ "$FS" == "btrfs" ]]; then
    mkfs.btrfs -f "$ROOT_PART"

    # Initial mount
    mount "$ROOT_PART" /mnt

    # Create subvolumes
    btrfs subvolume create /mnt/@ || true
    btrfs subvolume create /mnt/@snapshots || true
    [[ -z "$HOME_PART" || "$HOME_PART" == "none" ]] && \
        btrfs subvolume create /mnt/@home || true

    umount /mnt

    # Mount root and subvolumes
    mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
    mkdir -p /mnt/{home,.snapshots}
    mount -o noatime,compress=zstd,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots

    if [[ -z "$HOME_PART" || "$HOME_PART" == "none" ]]; then
        mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
    else
        mkfs.btrfs -f "$HOME_PART"
        mount "$HOME_PART" /mnt/home
    fi

else
    mkfs.ext4 -F "$ROOT_PART"
    mount "$ROOT_PART" /mnt

    if [[ -n "$HOME_PART" && "$HOME_PART" != "none" ]]; then
        mkfs.ext4 -F "$HOME_PART"
        mkdir -p /mnt/home
        mount "$HOME_PART" /mnt/home
    fi
fi


if [[ -n "$BOOT_PART" ]]; then
  mkdir -p /mnt/boot
  [[ "$BOOT_MODE" == "efi" ]] && mkfs.fat -F32 "$BOOT_PART" || mkfs.ext4 -F "$BOOT_PART"
  mount "$BOOT_PART" /mnt/boot
else
  mkdir -p /mnt/boot
fi

[[ -n "$SWAP_PART" ]] && mkswap "$SWAP_PART" && swapon "$SWAP_PART"