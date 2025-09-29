#!/usr/bin/env bash

CONF_FILE="./setup.conf"

# --- Default values ---
DEFAULT_DISK="sda"
DEFAULT_BOOT_PART="/dev/sda1"
DEFAULT_ROOT_PART="/dev/sda3"
DEFAULT_HOME_PART=""
DEFAULT_SWAP_PART=""
DEFAULT_BOOT_MODE="eif"
DEFAULT_HOSTNAME="myhost"
DEFAULT_USERNAME="user"
DEFAULT_ROOT_PASS="root123"
DEFAULT_USER_PASS="user123"
DEFAULT_FS="ext4"

DEFAULT_SNAP_MAX=3
DEFAULT_SNAP_DIR="/.snapshots"
DEFAULT_SNAP_TIME="03:00"

# --- Load config if it exists ---
if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
    echo "Loaded config from $CONF_FILE"
else
    echo "Config file not found. Let's set it up."

    # Prompt user with defaults
    read -rp "Enter disk [${DEFAULT_DISK}]: " DISK
    DISK="${DISK:-$DEFAULT_DISK}"

    read -rp "Enter boot partition [${DEFAULT_BOOT_PART}]: " BOOT_PART
    BOOT_PART="${BOOT_PART:-$DEFAULT_BOOT_PART}"

    read -rp "Enter root partition [${DEFAULT_ROOT_PART}]: " ROOT_PART
    ROOT_PART="${ROOT_PART:-$DEFAULT_ROOT_PART}"

    read -rp "Enter home partition [${DEFAULT_HOME_PART}]: " HOME_PART
    HOME_PART="${HOME_PART:-$DEFAULT_HOME_PART}"

    read -rp "Enter swap partition [${DEFAULT_SWAP_PART}]: " SWAP_PART
    SWAP_PART="${SWAP_PART:-$DEFAULT_SWAP_PART}"

    read -rp "Enter boot mode (efi/legacy) [${DEFAULT_BOOT_MODE}]: " BOOT_MODE
    BOOT_MODE="${BOOT_MODE:-$DEFAULT_BOOT_MODE}"

    read -rp "Enter hostname [${DEFAULT_HOSTNAME}]: " HOSTNAME
    HOSTNAME="${HOSTNAME:-$DEFAULT_HOSTNAME}"

    read -rp "Enter username [${DEFAULT_USERNAME}]: " USERNAME
    USERNAME="${USERNAME:-$DEFAULT_USERNAME}"

    read -rsp "Enter root password [${DEFAULT_ROOT_PASS}]: " ROOT_PASS; echo
    ROOT_PASS="${ROOT_PASS:-$DEFAULT_ROOT_PASS}"

    read -rsp "Enter user password [${DEFAULT_USER_PASS}]: " USER_PASS; echo
    USER_PASS="${USER_PASS:-$DEFAULT_USER_PASS}"

    read -rp "Enter filesystem type (ext4/btrfs) [${DEFAULT_FS}]: " FS
    FS="${FS:-$DEFAULT_FS}"

    read -rp "Max snapshots [${DEFAULT_SNAP_MAX}]: " SNAP_MAX
    SNAP_MAX="${SNAP_MAX:-$DEFAULT_SNAP_MAX}"

    read -rp "Snapshot directory [${DEFAULT_SNAP_DIR}]: " SNAP_DIR
    SNAP_DIR="${SNAP_DIR:-$DEFAULT_SNAP_DIR}"

    read -rp "Snapshot time (HH:MM) [${DEFAULT_SNAP_TIME}]: " SNAP_TIME
    SNAP_TIME="${SNAP_TIME:-$DEFAULT_SNAP_TIME}"

    # Save to config file
    cat > "$CONF_FILE" <<EOF
DISK="$DISK"
BOOT_PART="$BOOT_PART"
ROOT_PART="$ROOT_PART"
HOME_PART="$HOME_PART"
SWAP_PART="$SWAP_PART"
BOOT_MODE="$BOOT_MODE"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
ROOT_PASS="$ROOT_PASS"
USER_PASS="$USER_PASS"
FS="$FS"

SNAP_MAX="$SNAP_MAX"
SNAP_DIR="$SNAP_DIR"
SNAP_TIME="$SNAP_TIME"
EOF

    echo "Config saved to $CONF_FILE"
fi

# --- preview before confirming ---
echo
echo "======= Configuration Summary ======="
echo "Disk           : $DISK"
echo "Boot partition : $BOOT_PART"
echo "Root partition : $ROOT_PART"
echo "Home partition : $HOME_PART"
echo "Swap partition : $SWAP_PART"
echo "Boot mode      : $BOOT_MODE"
echo "Hostname       : $HOSTNAME"
echo "Username       : $USERNAME"
echo "Filesystem     : $FS"
echo "Snapshots      : max=$SNAP_MAX dir=$SNAP_DIR time=$SNAP_TIME"
echo "======================================"
echo

while true; do
    read -rp "Are these correct? [y/n]: " CONFIRM
    case "$CONFIRM" in
        [Yy]|[Yy][Ee][Ss])
            echo "✅ Proceeding with the confirmed configuration..."
            break
            ;;
        [Nn]|[Nn][Oo])
            echo "Aborted. You can edit $CONF_FILE or rerun the script."
            exit 1
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done
