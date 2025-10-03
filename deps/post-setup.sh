#!/bin/bash
set -e

# ===== Customize Hyde project =====
scriptDir="$HOME/.local/lib/hyde"
"${scriptDir}/wallbashtoggle.sh" 2
"${scriptDir}/theme.switch.sh" -s "Tokyo Night"


# ===== Install and Setup Conda =====
source /home/$USER/deps/install-conda.sh