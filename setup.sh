#!/bin/bash
set -e

# ===== VARIABLES =====
DOTFILES_REPO="https://github.com/akalmannakarmi/arch-setup.git"
USERNAME="$USER"

# ===== UPDATE SYSTEM =====
echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# ===== BASE DEVEL (needed for yay) =====
echo "==> Installing base-devel..."
sudo pacman -S --needed --noconfirm base-devel git

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
echo "==> Installing Hyprland + essentials..."
yay -S --noconfirm hyprland-git waybar wofi kitty polkit-gnome greetd greetd-tuigreet

# ===== BROWSERS =====
echo "==> Installing browsers..."
sudo pacman -S --noconfirm firefox chromium

# ===== SYSTEM TOOLS =====
echo "==> Installing useful tools..."
sudo pacman -S --noconfirm \
    neovim unzip p7zip htop btop fastfetch \
    networkmanager wget curl \
    papirus-icon-theme noto-fonts noto-fonts-emoji

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
user = '"$USERNAME"'
EOF'

sudo systemctl enable greetd

# ===== INSTALL & SETUP OH-MY-ZSH =====
echo "==> Installing zsh + oh-my-zsh..."
sudo pacman -S --noconfirm zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)" "$USERNAME"

# ===== DOTFILES =====
echo "==> Cloning dotfiles..."
if [ ! -d "$HOME/arch-setup" ]; then
    git clone "$DOTFILES_REPO" "$HOME/arch-setup"
else
    echo "Dotfiles already exist, skipping clone."
fi
echo "==> Copying dotfiles to home..."
cp -r "$HOME/arch-setup/dotfiles/." "$HOME/"


echo "==> Postinstall complete! Reboot to start greetd + Hyprland."
