#!/bin/bash
set -e

# Exit if script has already run
if [ -f "$HOME/arch-setup/.post-setup-done" ]; then
    exit 0
fi

# ===== Customize Hyde project =====
scriptDir="$HOME/.local/lib/hyde"
"${scriptDir}/wallbashtoggle.sh" 2
"${scriptDir}/theme.switch.sh" -s "Tokyo Night"


# ===== Install and Setup Conda =====
source /home/$USER/arch-setup/deps/install-conda.sh

read -n1 -r -p "Post Setup Complete! Press any key to exit"
echo