#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# === Arch Linux Automated Installer (fixed) ===

echo "=== Arch Linux Automated Installer ==="

# -------------------------
# Helper functions
# -------------------------
err() { echo "ERROR: $*" >&2; exit 1; }
confirm() {
  read -rp "$1 [y/N]: " _ans
  case "$_ans" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

# -------------------------
# User input
# -------------------------
read -rp "Enter root partition (e.g. /dev/sda3): " ROOT_PART
[ -b "$ROOT_PART" ] || err "Root partition $ROOT_PART does not exist (block device not found)."

read -rp "Enter boot partition (e.g. /dev/sda1) (leave blank to use / on root): " BOOT_PART
if [[ -n "$BOOT_PART" ]]; then
  [ -b "$BOOT_PART" ] || err "Boot partition $BOOT_PART does not exist (block device not found)."
fi

read -rp "Enter swap partition (leave blank if none): " SWAP_PART
if [[ -n "$SWAP_PART" ]]; then
  [ -b "$SWAP_PART" ] || err "Swap partition $SWAP_PART does not exist (block device not found)."
fi

read -rp "Boot mode (efi/legacy) [legacy]: " BOOT_MODE
BOOT_MODE=${BOOT_MODE:-legacy}
if [[ "$BOOT_MODE" != "efi" && "$BOOT_MODE" != "legacy" ]]; then
  err "Boot mode must be 'efi' or 'legacy'."
fi

read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -sp "Root password: " ROOT_PASS; echo
read -sp "User password: " USER_PASS; echo
read -rp "Filesystem on root (btrfs/ext4) [btrfs]: " FS
FS=${FS:-btrfs}
if [[ "$FS" != "btrfs" && "$FS" != "ext4" ]]; then
  err "Filesystem must be 'btrfs' or 'ext4'."
fi

echo
echo "SUMMARY:"
echo "  Root:   $ROOT_PART"
echo "  Boot:   ${BOOT_PART:-(none, will use / on root)}"
echo "  Swap:   ${SWAP_PART:-(none)}"
echo "  Mode:   $BOOT_MODE"
echo "  FS:     $FS"
echo "  Host:   $HOSTNAME"
echo "  User:   $USERNAME"
echo
confirm "Continue and format these partitions? THIS WILL DESTROY DATA ON THOSE PARTITIONS." || err "User aborted."

# -------------------------
# Convenience: detect disk (for BIOS grub-install)
# -------------------------
# Attempt to determine whole disk for grub-install when legacy mode.
get_disk_from_partition() {
  local part="$1"
  # prefer lsblk pkname
  local pk
  pk=$(lsblk -no PKNAME "$part" 2>/dev/null || true)
  if [[ -n "$pk" ]]; then
    echo "/dev/$pk"
    return 0
  fi
  # fallback: strip trailing partition digits (works for /dev/sda3)
  if [[ "$part" =~ ^(/dev/[a-z]+)[0-9]+$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  # fallback for nvme like /dev/nvme0n1p3 -> /dev/nvme0n1
  if [[ "$part" =~ ^(/dev/nvme[0-9]n[0-9]+)p[0-9]+$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

if [[ "$BOOT_MODE" == "legacy" ]]; then
  DISK=$(get_disk_from_partition "$ROOT_PART") || err "Unable to detect disk for $ROOT_PART (needed for grub install)."
  echo "Detected disk for grub install: $DISK"
fi

# -------------------------
# Format partitions
# -------------------------
echo ">> Formatting partitions..."

if [[ "$FS" == "btrfs" ]]; then
  echo " - mkfs.btrfs on $ROOT_PART"
  mkfs.btrfs -f "$ROOT_PART"
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@ || true
  btrfs subvolume create /mnt/@home || true
  btrfs subvolume create /mnt/@snapshots || true
  umount /mnt
  # mount subvolumes
  mount -o noatime,compress=zstd,subvol=@ "$ROOT_PART" /mnt
  mkdir -p /mnt/{home,.snapshots}
  mount -o noatime,compress=zstd,subvol=@home "$ROOT_PART" /mnt/home
  mount -o noatime,compress=zstd,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
else
  echo " - mkfs.ext4 on $ROOT_PART"
  mkfs.ext4 -F "$ROOT_PART"
  mount "$ROOT_PART" /mnt
fi

# Boot partition: create if given
if [[ -n "$BOOT_PART" ]]; then
  if [[ "$BOOT_MODE" == "efi" ]]; then
    echo " - mkfs.fat (FAT32) on $BOOT_PART for EFI boot"
    mkfs.fat -F32 "$BOOT_PART"
  else
    echo " - mkfs.ext4 on $BOOT_PART for legacy boot"
    mkfs.ext4 -F "$BOOT_PART"
  fi
  mkdir -p /mnt/boot
  mount "$BOOT_PART" /mnt/boot
else
  # if no separate boot, create /mnt/boot dir if needed (kernel will be on root)
  mkdir -p /mnt/boot
fi

# Swap
if [[ -n "$SWAP_PART" ]]; then
  echo " - setting up swap on $SWAP_PART"
  mkswap "$SWAP_PART"
  swapon "$SWAP_PART"
fi

# -------------------------
# Install base system
# -------------------------
echo ">> Installing base system (this will take a moment)..."
if [[ "$BOOT_MODE" == "efi" ]]; then
  pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs grub efibootmgr os-prober sudo
else
  pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs grub os-prober sudo
fi

# -------------------------
# fstab
# -------------------------
echo ">> Generating /etc/fstab..."
genfstab -U /mnt > /mnt/etc/fstab
echo "fstab written:"
cat /mnt/etc/fstab
echo

# -------------------------
# Chroot configuration
# -------------------------
echo ">> Entering chroot to finish configuration..."
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail
# hostname
echo "$HOSTNAME" > /etc/hostname

# timezone (UTC default)
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || true
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# root password
echo "root:$ROOT_PASS" | chpasswd

# create user
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASS" | chpasswd
# allow wheel sudo
if ! grep -q '^%wheel' /etc/sudoers 2>/dev/null; then
  echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers
fi

# enable network manager
systemctl enable NetworkManager

# mkinitcpio: ensure btrfs hook if using btrfs
if [ "$FS" = "btrfs" ]; then
  # Ensure 'btrfs' hook present before 'filesystems'
  sed -i -E "s/HOOKS=\((.*)\)/HOOKS=(\1)/" /etc/mkinitcpio.conf || true
  # add btrfs if missing (insert before filesystems)
  if ! grep -q 'btrfs' /etc/mkinitcpio.conf; then
    sed -i 's/\(filesystems\)/btrfs \1/' /etc/mkinitcpio.conf
  fi
fi
mkinitcpio -P

# GRUB install
if [ "$BOOT_MODE" = "efi" ]; then
  # Ensure /boot is mounted as EFI (FAT32)
  if [ ! -d /boot/EFI ] && [ -f /boot/vmlinuz-linux ]; then
    # ok, /boot mounted and vmlinuz present
    :
  fi
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
  grub-mkconfig -o /boot/grub/grub.cfg
else
  # Legacy BIOS: install grub to whole disk (not partition)
  if [ -z "${DISK:-}" ]; then
    echo "DISK variable not set in chroot; cannot install grub to disk" >&2
    exit 1
  fi
  echo "Installing GRUB to disk: $DISK"
  grub-install --target=i386-pc "$DISK"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

EOF

# -------------------------
# Final message and cleanup
# -------------------------
echo "=== Installation finished. ==="
echo "If everything went well, reboot now: sudo umount -R /mnt ; swapoff -a ; reboot"
echo "If you used legacy BIOS mode, grub was installed to: ${DISK:-(unknown)}"
