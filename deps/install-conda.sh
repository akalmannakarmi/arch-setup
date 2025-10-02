#!/bin/bash
# Auto-install Miniconda for zsh without prompts

# Variables
MINICONDA_DIR="$HOME/miniconda3"
INSTALLER="$HOME/miniconda.sh"
URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

# Download installer
echo "Downloading Miniconda..."
wget -O "$INSTALLER" "$URL"

# Run installer silently
echo "Installing Miniconda..."
bash "$INSTALLER" -b -p "$MINICONDA_DIR"

# Initialize conda for zsh
echo "Initializing conda for zsh..."
"$MINICONDA_DIR/bin/conda" init zsh

# Remove installer
rm "$INSTALLER"

# Source zsh config to apply changes immediately
source ~/.zshrc

# Test installation
echo "Miniconda installed at $MINICONDA_DIR"
conda --version
