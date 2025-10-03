#!/usr/bin/env bash

# --- Format partitions ---
# --- Format and mount root filesystem ---
if [[ "$FS" == "btrfs" ]]; then
    mkfs.btrfs -f "$ROOT_PART"

    # Initial mount to top-level
    mount -o subvolid=5 "$ROOT_PART" /mnt

    # Create base subvolumes
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@snapshots
    [[ -z "$HOME_PART" || "$HOME_PART" == "none" ]] && \
        btrfs subvolume create /mnt/@home

    # Create "current" snapshots for boot
    btrfs subvolume snapshot /mnt/@ /mnt/@snapshots/cur_root
    if [[ -z "$HOME_PART" || "$HOME_PART" == "none" ]]; then
        btrfs subvolume snapshot /mnt/@home /mnt/@snapshots/cur_home
    fi

    umount /mnt

    # Mount snapshots as system root and home
    mount -o noatime,compress=zstd,subvol=@snapshots/cur_root "$ROOT_PART" /mnt
    mkdir -p /mnt/{home,.snapshots}

    mount -o noatime,compress=zstd,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots

    if [[ -z "$HOME_PART" || "$HOME_PART" == "none" ]]; then
        mount -o noatime,compress=zstd,subvol=@snapshots/cur_home "$ROOT_PART" /mnt/home
    else
        mkfs.btrfs -f "$HOME_PART"
        mount "$HOME_PART" /mnt/home
    fi
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