#!/usr/bin/env bash
set -euo pipefail

WAYBAR_SIGNAL="${WAYBAR_SIGNAL:-11}"

have() { command -v "$1" >/dev/null 2>&1; }

get_mode() {
  if ! have powerprofilesctl; then
    echo "unavailable"
    return
  fi
  powerprofilesctl get 2>/dev/null | tr -d '\r\n' || echo "unavailable"
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
      tooltip="Power mode: unavailable (run nrs)"
      cls="mode-unavailable"
      icon="󰾆"
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

  powerprofilesctl set "$next" >/dev/null 2>&1 || exit 1
  pkill -SIGRTMIN+"$WAYBAR_SIGNAL" -x waybar 2>/dev/null || true
}

case "${1:-}" in
  --status|"")
    print_status
    ;;
  --cycle)
    cycle_mode
    ;;
  *)
    echo "Usage: $0 [--status|--cycle]" >&2
    exit 2
    ;;
esac
