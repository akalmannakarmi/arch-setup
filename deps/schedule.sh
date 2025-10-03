#!/bin/bash
set -e

mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/post-setup.service <<EOF
[Unit]
Description=Post-setup script in Kitty
After=hyprland-session.target
Wants=hyprland-session.target

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c 'while ! kitty -e true >/dev/null 2>&1; do sleep 1; done'
ExecStart=/usr/bin/kitty --hold /home/%u/arch-setup/deps/post-setup.sh
ExecStartPost=/usr/bin/systemctl --user disable post-setup.service
RemainAfterExit=no

[Install]
WantedBy=default.target
EOF

# Reload systemd user units so it sees the new service
systemctl --user daemon-reload
systemctl --user enable post-setup.service