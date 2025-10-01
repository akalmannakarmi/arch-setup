#!/bin/bash
set -e

# ===== Install yay and install packages =====
source ./scripts/install-pkg.sh

# ===== ENABLE Services =====
source ./scripts/enable-services.sh

# ===== SETUP OH-MY-ZSH =====
source ./scripts/setup-omz.sh

# ===== DOTFILES =====
source ./scripts/copy-dotfiles.sh

echo "==> Setup complete! Reboot to start greetd + Hyprland."
