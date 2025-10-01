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