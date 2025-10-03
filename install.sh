#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "=== Arch Linux Automated Installer ==="

# Load config
source ./deps/variables.sh

# Format and Mount partitions
echo "Formating Partitions"
source ./deps/partitions.sh


# --- Base install ---
echo "Installing basic linux and packages"
pacstrap /mnt base linux linux-firmware nano \
    broadcom-wl networkmanager iwd dhclient\
    btrfs-progs sudo grub os-prober efibootmgr base-devel git --noconfirm
genfstab -U /mnt > /mnt/etc/fstab

# btrfs auto snapshots
if [[ "$FS" == "btrfs" ]]; then
  # --- Install snapshot script ---
  mkdir -p /mnt/usr/local/bin
  cp ./deps/snapshot.sh /mnt/usr/local/bin/snapshot.sh

  # --- Setup cron ---
  mkdir -p /mnt/etc/cron.d
  cp ./deps/cron.btrfs /mnt/etc/cron.d/btrfs-snapshots
fi

echo "Copying Over the setup script"
mkdir -p "/mnt/arch-setup"
cp -r . "/mnt/home/$USERNAME/arch-setup"


echo "Entering installed arch Environment"
arch-chroot /mnt /bin/bash <<EOF
cd /arch-setup
./deps/base-chroot.sh
EOF

while true; do
    read -rp "Would you like to setup hyperland? [y/n]: " CONFIRM
    case "$CONFIRM" in
        [Yy]|[Yy][Ee][Ss])
            echo "✅ Proceeding with arch hyperland setup..."
            break
            ;;
        [Nn]|[Nn][Oo])
            echo "Unmounting partitions"
            umount -R /mnt
            swapoff -a
            echo "Reboot to use your arch installation"
            exit 1
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done


echo "Entering installed arch Environment"
arch-chroot /mnt /bin/bash <<EOF
su $USERNAME
cd /arch-setup
./setup.sh
EOF


echo "Unmounting partitions"
umount -R /mnt
swapoff -a
