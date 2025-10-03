#!/bin/bash
set -e

# ===== Install personalized HyDE project =====
source ./deps/hyde-install.sh


# ===== Customize Hyde project =====
# scriptDir="$HOME/.local/lib/hyde"
# "${scriptDir}/wallbashtoggle.sh" 2
# "${scriptDir}/theme.switch.sh" -s "Tokyo Night"


# # ===== Setup Docker =====
# sudo systemctl enable --now docker
# sudo usermod -aG docker $USER


# # ===== Install and Setup Conda =====
# source ./deps/install-conda.sh


# # ===== Copy custom Scripts =====
# source ./deps/copy-scripts.sh

echo "==> Setup complete!"
