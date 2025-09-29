#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "=== Arch Linux Automated Installer ==="

# Load config
source ./scripts/variables.sh

# Format and Mount partitions
source ./scripts/partitions.sh


# --- Base install ---
pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs sudo grub os-prober efibootmgr --noconfirm
genfstab -U /mnt > /mnt/etc/fstab


# # --- Install snapshot script ---
# mkdir -p /mnt/usr/local/bin
# cp ./deps/snapshot.sh /mnt/usr/local/bin/snapshot.sh
# chmod +x /mnt/usr/local/bin/snapshot.sh

# # --- Setup cron ---
# mkdir -p /mnt/etc/cron.d
# cp ./deps/cron.btrfs /mnt/etc/cron.d/btrfs-snapshots

arch-chroot /mnt /bin/bash ./scripts/base-chroot.sh

mkdir -p "/mnt/home/$USERNAME/arch-setup"
cp -r . "/mnt/home/$USERNAME/arch-setup"