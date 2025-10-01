#!/bin/bash
set -e

git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
cd ~/HyDE/Scripts
./install.sh

# # ===== Install yay and install packages =====
# source ./deps/install-pkg.sh

# # ===== ENABLE Services =====
# source ./deps/enable-services.sh

# # ===== SETUP OH-MY-ZSH =====
# source ./deps/setup-omz.sh

# # ===== DOTFILES =====
# source ./deps/copy-dotfiles.sh

# # ===== DOTFILES =====
# source ./deps/copy-scripts.sh

echo "==> Setup complete!"
