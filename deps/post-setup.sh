#!/bin/bash
set -e

# File that marks the script has already run
FLAG="$HOME/arch-setup/.post-setup-done"

# Exit if script has already run
if [ -f "$FLAG" ]; then
    exit 0
fi

# ===== Customize Hyde project =====
scriptDir="$HOME/.local/lib/hyde"
source "${scriptDir}/wallbashtoggle.sh" 2
source "${scriptDir}/theme.switch.sh" -s "Tokyo Night"


# ===== Install and Setup Conda =====
source /home/$USER/arch-setup/deps/install-conda.sh

read -n1 -r -p "Post Setup Complete! Press any key to exit"
echo