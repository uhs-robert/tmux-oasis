#!/usr/bin/env bash
# Usage: disk.sh display|state
# Used percent of the filesystem holding @oasis_disk_path.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

[ "$(oasis_platform)" = unsupported ] && exit 0
path=$(oasis_option @oasis_disk_path /)
# On APFS "/" is the sealed system volume, which is nearly empty; the user's data is on this one
: "${OASIS_MACOS_DATA_VOLUME:=/System/Volumes/Data}"
if [ "$(oasis_platform)" = macos ] && [ "$path" = / ] && [ -d "$OASIS_MACOS_DATA_VOLUME" ]; then
  path=$OASIS_MACOS_DATA_VOLUME
fi

used=$(df -P "$path" 2>/dev/null | awk '
  # The first column can hold spaces, so find the capacity instead of counting to it
  NR == 2 { for (i = 2; i <= NF; i++) if ($i ~ /^[0-9]+%$/) { sub(/%/, "", $i); print $i; exit } }')
oasis_report "${1:-}" "$used" "%" disk 80 90
