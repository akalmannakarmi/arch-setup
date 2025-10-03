#!/bin/bash
# Auto-install Miniconda silently

MINICONDA_DIR="$HOME/miniconda3"
INSTALLER="$HOME/miniconda.sh"
URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

echo "Downloading Miniconda..."
wget -O "$INSTALLER" "$URL"

echo "Installing Miniconda..."
bash "$INSTALLER" -b -p "$MINICONDA_DIR"

echo "Initializing conda for Zsh..."
zsh -ic "$MINICONDA_DIR/bin/conda init zsh"

rm "$INSTALLER"

echo "Miniconda installed at $MINICONDA_DIR"
zsh -ic "conda --version"
