#!/usr/bin/env bash
set -euo pipefail

# Load config
SKIP_CONFIRM=true
source ./deps/variables.sh

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Locale
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Users
echo "root:$ROOT_PASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASS" | chpasswd
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Enable networking
systemctl enable NetworkManager

# mkinitcpio for btrfs
if [ "$FS" = "btrfs" ]; then
  sed -i 's/\(filesystems\)/btrfs \1/' /etc/mkinitcpio.conf
fi
mkinitcpio -P

# GRUB
if [ "$BOOT_MODE" = "efi" ]; then
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
else
  grub-install --target=i386-pc "$DISK"
fi
grub-mkconfig -o /boot/grub/grub.cfg