#!/usr/bin/env bash

set -euo pipefail

out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"

file="$out_dir/$(date +%Y-%m-%d_%H-%M-%S).png"
# Keep subtle visual guidance while selecting.
geometry="$(slurp -w 2 -b 00000044 -c 7aa2f7ff -s 7aa2f733 2>/dev/null || true)"

if [[ -z "$geometry" ]]; then
  exit 0
fi

# Give compositor time to clear selection overlay before capture.
sleep 0.15
grim -g "$geometry" "$file"
wl-copy < "$file"
notify-send "Screenshot saved" "$(basename "$file") copied to clipboard"
