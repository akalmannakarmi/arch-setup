#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# === Arch Linux Automated Installer ===

echo "=== Arch Linux Automated Installer ==="

# --- Helper functions ---
err() { echo "ERROR: $*" >&2; exit 1; }
confirm() {
  read -rp "$1 [y/N]: " _ans
  case "$_ans" in [Yy]|[Yy][Ee][Ss]) return 0 ;; *) return 1 ;; esac
}

# --- User input ---
read -rp "Enter root partition (e.g. /dev/sda3): " ROOT_PART
[ -b "$ROOT_PART" ] || err "Root partition $ROOT_PART does not exist."

read -rp "Enter boot partition (leave blank to use / on root): " BOOT_PART
[[ -z "$BOOT_PART" ]] || [ -b "$BOOT_PART" ] || err "Boot partition $BOOT_PART does not exist."

read -rp "Enter swap partition (leave blank if none): " SWAP_PART
[[ -z "$SWAP_PART" ]] || [ -b "$SWAP_PART" ] || err "Swap partition $SWAP_PART does not exist."

read -rp "Boot mode (efi/legacy) [legacy]: " BOOT_MODE
BOOT_MODE=${BOOT_MODE:-legacy}
[[ "$BOOT_MODE" == "efi" || "$BOOT_MODE" == "legacy" ]] || err "Boot mode must be 'efi' or 'legacy'."

read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -sp "Root password: " ROOT_PASS; echo
read -sp "User password: " USER_PASS; echo
read -rp "Filesystem (btrfs/ext4) [btrfs]: " FS
FS=${FS:-btrfs}
[[ "$FS" == "btrfs" || "$FS" == "ext4" ]] || err "Filesystem must be 'btrfs' or 'ext4'."

echo
echo "Summary:"
echo " Root:   $ROOT_PART"
echo " Boot:   ${BOOT_PART:-(none)}"
echo " Swap:   ${SWAP_PART:-(none)}"
echo " Mode:   $BOOT_MODE"
echo " FS:     $FS"
echo " Host:   $HOSTNAME"
echo " User:   $USERNAME"
confirm "Continue and format partitions? THIS WILL ERASE DATA." || err "Aborted."

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

# --- Install base system ---
pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs timeshift sudo grub os-prober efibootmgr --noconfirm

# --- FSTAB ---
genfstab -U /mnt > /mnt/etc/fstab

# --- Chroot configuration ---
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Hostname
echo "$HOSTNAME" > /etc/hostname

# Timezone and locale
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

# Enable network
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

# Configure Timeshift for Btrfs root snapshots
timeshift --create --comments "Initial snapshot" --tags D
timeshift --schedule --daily

# Pre-upgrade snapshots hook for pacman & yay
mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/10-timeshift.hook <<HEOF
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Create Timeshift snapshot before upgrade
When = PreTransaction
Exec = /usr/bin/timeshift --create --comments "Before upgrade" --tags D
HEOF

EOF

echo "=== Installation complete. ==="
echo "Reboot now: sudo umount -R /mnt ; swapoff -a ; reboot"
