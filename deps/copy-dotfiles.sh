
echo "==> Backing up existing config..."
BACKUP_DIR="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Only back up what we’re going to replace
for dir in hypr waybar wofi mako swaylock kitty; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backing up $dir to $BACKUP_DIR/$dir"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

echo "==> Copying config..."
if [ -d ".config" ]; then
    cp -r .config/* "$HOME/.config/"
else
    echo "No config folder found, skipping."
fi