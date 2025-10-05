#!/bin/bash
set -e

FLAG="$HOME/arch-setup/.post-setup-done"

# Exit if script has already run
if [ -f "$FLAG" ]; then
    exit 0
fi

# ===== Customize Hyde project =====
scriptDir="$HOME/.local/lib/hyde"

# Run both scripts in background, redirect output to /dev/null
nohup "${scriptDir}/wallbashtoggle.sh" 2 >/dev/null 2>&1 &
nohup "${scriptDir}/theme.switch.sh" -s "Tokyo Night" >/dev/null 2>&1 &


# ===== Fix opera ffmpeg =====
sudo /home/"$USER"/arch-setup/deps/fix-opera.sh

# ===== Mark complete =====
touch "$FLAG"
echo "Post Setup Complete!"
