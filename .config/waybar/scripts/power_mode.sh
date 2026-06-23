#!/usr/bin/env bash
set -euo pipefail

WAYBAR_SIGNAL="${WAYBAR_SIGNAL:-11}"

have() { command -v "$1" >/dev/null 2>&1; }

get_mode() {
  if ! have powerprofilesctl; then
    echo "unavailable"
    return
  fi
  # Trim whitespace
  powerprofilesctl get 2>/dev/null | xargs echo -n || echo "unavailable"
}

print_status() {
  local mode tooltip cls icon
  mode="$(get_mode)"
  
  case "$mode" in
    performance)
      tooltip="Power mode: performance"
      cls="mode-performance"
      icon="󰓅"
      ;;
    balanced)
      tooltip="Power mode: balanced"
      cls="mode-balanced"
      icon="󰾅"
      ;;
    power-saver)
      tooltip="Power mode: power-saver"
      cls="mode-powersaver"
      icon="󰾆"
      ;;
    *)
      tooltip="Power mode: $mode (unavailable)"
      cls="mode-unavailable"
      icon="󰅚"
      ;;
  esac

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$icon" "$cls" "$tooltip"
}

cycle_mode() {
  have powerprofilesctl || exit 0

  local mode next
  mode="$(get_mode)"
  case "$mode" in
    performance) next="balanced" ;;
    balanced) next="power-saver" ;;
    power-saver) next="performance" ;;
    *) next="balanced" ;;
  esac

  set_mode "$next"
}

set_mode() {
  have powerprofilesctl || exit 0
  local target="$1"
  
  # Set power profile
  powerprofilesctl set "$target" >/dev/null 2>&1 || exit 1
  
  # Wait briefly for state change
  local i=0
  while [ "$i" -lt 5 ]; do
    [ "$(get_mode)" = "$target" ] && break
    sleep 0.1
    i=$((i + 1))
  done

  # Signal waybar to update icon
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

case "${1:-}" in
  --status|"")
    print_status
    ;;
  --get-only)
    get_mode
    ;;
  --cycle)
    cycle_mode
    ;;
  --set)
    [ -n "${2:-}" ] || exit 1
    set_mode "$2"
    ;;
  *)
    echo "Usage: $0 [--status|--get-only|--cycle|--set <mode>]" >&2
    exit 2
    ;;
esac
