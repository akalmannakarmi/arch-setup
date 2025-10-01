#!/bin/bash
set -e

# ===== Install yay and install packages =====
source ./deps/install-pkg.sh

# ===== ENABLE Services =====
source ./deps/enable-services.sh

# ===== SETUP OH-MY-ZSH =====
source ./deps/setup-omz.sh

# ===== DOTFILES =====
source ./deps/copy-dotfiles.sh

# ===== DOTFILES =====
source ./deps/copy-scipts.sh

echo "==> Setup complete! Reboot to start greetd + Hyprland."
