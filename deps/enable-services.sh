
echo "==> Enabling NetworkManager..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable systemd-timesyncd

# ===== CONFIGURE GREETD =====
echo "==> Configuring greetd..."
sudo bash -c 'cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = '"$USER"'
EOF'

sudo systemctl enable greetd