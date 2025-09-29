#!/usr/bin/env bash
set -euo pipefail

SNAP_DIR="${SNAP_DIR:-/.snapshots}"
ROOT_SUBVOL="${ROOT_SUBVOL:-@}"
MAX_SNAP="${SNAP_MAX:-3}"

DATE=$(date +%Y%m%d-%H%M%S)
# Create snapshot
btrfs subvolume snapshot / "$SNAP_DIR/$DATE"

# Prune old snapshots
cd "$SNAP_DIR"
count=$(ls -1d */ 2>/dev/null | wc -l)
while [ "$count" -gt "$MAX_SNAP" ]; do
    oldest=$(ls -1d */ | head -n1)
    btrfs subvolume delete "$oldest"
    count=$((count-1))
done
