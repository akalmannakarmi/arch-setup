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
"${scriptDir}/wallbashtoggle.sh" 2
"${scriptDir}/theme.switch.sh" -s "Tokyo Night"


# ===== Fix opera ffmpeg =====
source /home/$USER/arch-setup/deps/fix-opera.sh

touch "$FLAG"

echo "Post Setup Complete!"