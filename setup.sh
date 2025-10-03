#!/bin/bash
set -e

# ===== Install personalized HyDE project =====
./deps/hyde-install.sh


# ===== Setup Docker =====
sudo systemctl enable --now docker
sudo usermod -aG docker $USER


# # ===== Copy custom Scripts =====
# ./deps/copy-scripts.sh

# # ===== Post setup =====
./deps/schedule.sh


echo "==> Setup complete! Please reboot to use changes"
