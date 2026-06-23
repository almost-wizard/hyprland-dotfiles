#!/usr/bin/env bash

set -euo pipefail

out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"

file="$out_dir/$(date +%Y-%m-%d_%H-%M-%S).png"

monitor="$(
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name' | head -n1
)"

if [[ -z "$monitor" ]]; then
  notify-send "Screenshot failed" "No active monitor to capture"
  exit 1
fi

grim -o "$monitor" "$file"
wl-copy < "$file"
notify-send "Screenshot saved" "$(basename "$file") copied to clipboard"
