#!/bin/bash
set -e

scriptDir="$HOME/.local/lib/hyde"

source ./deps/hyde-install.sh

"${scriptDir}/wallbashtoggle.sh" 2
"${scriptDir}/theme.switch.sh" -s "Tokyo Night"

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
