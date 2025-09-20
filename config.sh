#!/usr/bin/env bash
# --- User configuration ---

ROOT_PART="/dev/sda3"
BOOT_PART="/dev/sda1"
SWAP_PART="/dev/sda4"
BOOT_MODE="legacy"   # efi or legacy
HOSTNAME="archpc"
USERNAME="user"
ROOT_PASS="rootpassword"
USER_PASS="userpassword"
FS="btrfs"           # btrfs or ext4

# Snapshot config
SNAP_MAX=3
SNAP_DIR="/.snapshots"
SNAP_TIME="03:00"    # daily snapshot time (HH:MM)
