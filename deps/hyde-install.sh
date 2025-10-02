REPO_URL="https://github.com/akalmannakarmi/HyDE-personalized.git"
INSTALL_DIR="$HOME/HyDE"

# Check if repo already exists
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd "$INSTALL_DIR" || exit 1
    git pull
else
    echo "Cloning repository..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Run install script
cd "$INSTALL_DIR/Scripts" || exit 1
chmod +x install.sh
./install.sh