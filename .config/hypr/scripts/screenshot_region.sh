#!/usr/bin/env bash

set -euo pipefail

out_dir="$HOME/Pictures/Screenshots"
mkdir -p "$out_dir"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
state_file="$state_dir/last_screenshot_region"
mkdir -p "$state_dir"

mode="${1:-select}"

capture() {
  local geometry="$1"
  local file
  file="$out_dir/$(date +%Y-%m-%d_%H-%M-%S).png"

  # Give compositor time to clear selection overlay before capture.
  sleep 0.15
  grim -g "$geometry" "$file"
  wl-copy < "$file"
  printf '%s\n' "$geometry" > "$state_file"
  notify-send "Screenshot saved" "$(basename "$file") copied to clipboard"
}

case "$mode" in
  select)
    # Keep subtle visual guidance while selecting.
    geometry="$(slurp -w 2 -b 00000044 -c 7aa2f7ff -s 7aa2f733 2>/dev/null || true)"
    [[ -z "$geometry" ]] && exit 0
    capture "$geometry"
    ;;
  --last|--repeat)
    if [[ ! -s "$state_file" ]]; then
      notify-send "Screenshot" "No previous region found"
      exit 1
    fi
    geometry="$(<"$state_file")"
    [[ -z "$geometry" ]] && exit 1
    capture "$geometry"
    ;;
  *)
    echo "Usage: $(basename "$0") [select|--last|--repeat]" >&2
    exit 2
    ;;
esac
