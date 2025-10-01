#!/bin/bash
set -e

# ===== UPDATE SYSTEM =====
echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# ===== INSTALL yay =====
echo "==> Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
else
    echo "yay already installed."
fi

# ===== HYPRLAND + ESSENTIALS =====
echo "==> Installing Hyprland + Essentials + Browsers + Tools ....."
yay -S --noconfirm hyprland-git waybar wofi kitty polkit-gnome greetd greetd-tuigreet \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber bluez bluez-utils \
    pavucontrol blueman network-manager-applet gvfs thunar xdg-desktop-portal-hyprland \
    swaylock-effects swayidle hyprpaper mako zsh \
    lxappearance-gtk3 kvantum-qt6 catppuccin-gtk-theme tokyo-night-gtk-theme papirus-icon-theme \
    noto-fonts noto-fonts-emoji candy-icons ttf-jetbrains-mono-nerd ttf-font-awesome \
    neovim unzip p7zip htop btop fastfetch wget curl \
    firefox chromium opera-git

# ===== ENABLE NETWORKMANAGER =====
echo "==> Enabling NetworkManager..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable systemd-timesyncd

# ===== CONFIGURE GREETD =====
echo "==> Configuring greetd..."
sudo bash -c 'cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = '"$USER"'
EOF'

sudo systemctl enable greetd

# ===== SETUP OH-MY-ZSH =====
source ./scripts/setup-omz.sh

# ===== DOTFILES =====
echo "==> Backing up existing config..."
BACKUP_DIR="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Only back up what we’re going to replace
for dir in hypr waybar wofi mako swaylock kitty; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backing up $dir to $BACKUP_DIR/$dir"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

echo "==> Copying config..."
if [ -d ".config" ]; then
    cp -r .config/* "$HOME/.config/"
else
    echo "No config folder found, skipping."
fi

echo "==> Setup complete! Reboot to start greetd + Hyprland."
