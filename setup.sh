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
    pavucontrol blueman network-manager-applet gvfs thunar xdg-desktop-portal-hyprland\
    swaylock-effects swayidle hyprpaper mako zsh\
    neovim unzip p7zip htop btop fastfetch wget curl\
    lxappearance-gtk3 kvantum-qt6 catppuccin-gtk-theme tokyo-night-gtk-theme papirus-icon-theme\
    noto-fonts noto-fonts-emoji candy-icons ttf-jetbrains-mono-nerd ttf-font-awesome \
    firefox chromium opera-git

# ===== ENABLE NETWORKMANAGER =====
echo "==> Enabling NetworkManager..."
sudo systemctl enable NetworkManager

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
source ./scripts/setup-omzsh

# ===== DOTFILES =====
echo "==> Copying dotfiles..."
if [ -d "./dotfiles" ]; then
    cp -r ./dotfiles/. "$HOME/"
else
    echo "No dotfiles folder found, skipping."
fi

echo "==> Postinstall complete! Reboot to start greetd + Hyprland."
