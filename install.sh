#!/bin/bash
set -e

echo "=== Arch Linux Automated Installer ==="

# --- USER INPUT ---
read -p "Enter root partition (e.g. /dev/sda3): " ROOT_PART
read -p "Enter boot partition (e.g. /dev/sda1): " BOOT_PART
read -p "Enter swap partition (leave blank if none): " SWAP_PART
read -p "Boot mode (efi/legacy): " BOOT_MODE
read -p "Hostname: " HOSTNAME
read -p "Username: " USERNAME
read -sp "Root password: " ROOT_PASS; echo
read -sp "User password: " USER_PASS; echo
read -p "Filesystem (btrfs/ext4) [btrfs]: " FS
FS=${FS:-btrfs}

# --- FORMAT PARTITIONS ---
echo ">> Formatting partitions..."
if [[ "$FS" == "btrfs" ]]; then
  mkfs.btrfs -f "$ROOT_PART"
  mount "$ROOT_PART" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@snapshots
  umount /mnt
  mount -o subvol=@,compress=zstd "$ROOT_PART" /mnt
  mkdir -p /mnt/{boot,home,.snapshots}
  mount -o subvol=@home,compress=zstd "$ROOT_PART" /mnt/home
  mount -o subvol=@snapshots,compress=zstd "$ROOT_PART" /mnt/.snapshots
else
  mkfs.ext4 -F "$ROOT_PART"
  mount "$ROOT_PART" /mnt
  mkdir -p /mnt/boot
fi

if [[ "$BOOT_MODE" == "efi" ]]; then
  mkfs.fat -F32 "$BOOT_PART"
else
  mkfs.ext4 -F "$BOOT_PART"
fi
mount "$BOOT_PART" /mnt/boot

if [[ -n "$SWAP_PART" ]]; then
  mkswap "$SWAP_PART"
  swapon "$SWAP_PART"
fi

# --- INSTALL BASE SYSTEM ---
echo ">> Installing base system..."
pacstrap /mnt base linux linux-firmware nano networkmanager btrfs-progs grub efibootmgr os-prober sudo

# --- FSTAB ---
genfstab -U /mnt >> /mnt/etc/fstab

# --- CHROOT CONFIG ---
arch-chroot /mnt /bin/bash <<EOF
echo "$HOSTNAME" > /etc/hostname

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "root:$ROOT_PASS" | chpasswd

useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$USER_PASS" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

systemctl enable NetworkManager

if [[ "$BOOT_MODE" == "efi" ]]; then
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
else
  grub-install --target=i386-pc $ROOT_PART
fi
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "=== Installation complete. Reboot when ready. ==="
