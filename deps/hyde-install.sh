REPO_URL="https://github.com/akalmannakarmi/HyDE-personalized.git"
INSTALL_DIR="$HOME/HyDE"

# Check if repo already exists
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Repository already exists. Fetching latest commit only..."
    cd "$INSTALL_DIR" || exit 1
    git fetch --depth 1 origin master
    git reset --hard origin/master
else
    echo "Cloning repository..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Run install script
cd "$INSTALL_DIR/Scripts" || exit 1
chmod +x install.sh
./install.sh