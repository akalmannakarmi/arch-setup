#!/bin/bash
set -e

# Paths
FLAG="$HOME/arch-setup/.post-setup-done"
SCRIPT_PATH="$HOME/arch-setup/deps/post-setup.sh"
AUTOSTART="$HOME/.config/hypr/autostart.conf"

# ===== Reset flag if it exists =====
if [ -f "$FLAG" ]; then
    echo "Removing old post-setup flag..."
    rm -f "$FLAG"
fi

# ===== Ensure autostart.conf exists and add this script =====
mkdir -p "$(dirname "$AUTOSTART")"
touch "$AUTOSTART"

if ! grep -Fxq "kitty --hold $SCRIPT_PATH" "$AUTOSTART"; then
    echo "Adding post-setup script to Hyprland autostart..."
    echo "kitty --hold $SCRIPT_PATH" >> "$AUTOSTART"
else
    echo "Post-setup script already in autostart"
fi