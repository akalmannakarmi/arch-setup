#!/bin/bash
set -e

mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/post-setup.service <<EOF
[Unit]
Description=Run script only on first login for post setup
After=default.target

[Service]
Type=oneshot
ExecStart=/home/$USER/arch-setup/deps/post-setup.sh
RemainAfterExit=no

[Install]
WantedBy=default.target
EOF

# Reload systemd user units so it sees the new service
systemctl --user daemon-reload
systemctl --user enable post-setup.service