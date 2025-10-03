#!/bin/bash
set -e

mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/post-setup.service <<EOF
[Unit]
Description=Post-setup script in Kitty
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=oneshot
Environment="XDG_RUNTIME_DIR=%t"
Environment="WAYLAND_DISPLAY=wayland-1"
ExecStart=/usr/bin/kitty --hold /home/%u/arch-setup/deps/post-setup.sh
ExecStartPost=/usr/bin/systemctl --user disable post-setup.service

[Install]
WantedBy=graphical-session.target
EOF

# Reload systemd user units so it sees the new service
systemctl --user daemon-reload
systemctl --user enable post-setup.service