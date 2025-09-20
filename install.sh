#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "=== Arch Linux Automated Installer ==="

# Load config
source ./config.sh

# --- Detect disk for BIOS grub-install ---
get_disk_from_partition() {
  local part="$1"
  local pk
  pk=$(lsblk -no PKNAME "$part" 2>/dev/null || true)
  [[ -n "$pk" ]] && echo "/dev/$pk" && return 0
  [[ "$part" =~ ^(/dev/[a-z]+)[0-9]+$ ]] && echo "${BASH_REMATCH[1]}" && return 0
  [[ "$part" =~ ^(/dev/nvme[0-9]n[0-9]+)p[0-9]+$ ]] && echo "${BASH_REMATCH[1]}" && return 0
  return 1
}

[[ "$BOOT_MODE" == "legacy" ]] && DISK=$(get_disk_from_partition "$ROOT_PART") || true

# --- Format partitions ---
if [[ "$FS" == "btrfs" ]]; then
  mkfs.btrfs -f "$ROOT_PART"
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@ || true
  btrfs subvolume create /mnt/@home || true
  btrfs subvolume create /mnt/@snapshots || true
  umount /mnt
  mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
  mkdir -p /mnt/{home,.snapshots}
  mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
  mount -o noatime,compress=zstd,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
else
  mkfs.ext4 -F "$ROOT_PART"
  mount "$ROOT_PART" /mnt
fi

if [[ -n "$BOOT_PART" ]]; then
  mkdir -p /mnt/boot
  [[ "$BOOT_MODE" == "efi" ]] && mkfs.fat -F32 "$BOOT_PART" || mkfs.ext4 -F "$BOOT_PART"
  mount "$BOOT_PART" /mnt/boot
else
  mkdir -p /mnt/boot
fi

[[ -n "$SWAP_PART" ]] && mkswap "$SWAP_PART" && swapon "$SWAP_PART"


# --- Base install ---
pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs sudo grub os-prober efibootmgr --noconfirm
genfstab -U /mnt > /mnt/etc/fstab


# --- Install snapshot script ---
mkdir -p /mnt/usr/local/bin
cp ./deps/snapshot.sh /mnt/usr/local/bin/snapshot.sh
chmod +x /mnt/usr/local/bin/snapshot.sh

# --- Setup cron ---
mkdir -p /mnt/etc/cron.d
cp ./deps/cron.btrfs /etc/cron.d/btrfs-snapshots

arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

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
echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers

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
EOF

echo "=== Installation complete. Automated Btrfs snapshots via cron are configured. ==="
echo "Reboot: sudo umount -R /mnt ; swapoff -a ; reboot"
