#!/usr/bin/env bash
set -euo pipefail

# Start the lock screen when requested, then turn DPMS back on.
# Resume can be racy; retry a bit until Hyprland IPC is ready.
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
resume_only=0

if [[ "${1:-}" == "--resume" ]]; then
  resume_only=1
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  socket="$runtime_dir/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  for _ in $(seq 1 30); do
    [[ -S "$socket" ]] && break
    sleep 0.1
  done
fi

if [[ "$resume_only" == "0" ]] && ! pgrep -xu "$USER" hyprlock >/dev/null 2>&1; then
  hyprlock >/dev/null 2>&1 &
  disown || true
fi

dpms_ok=0
for _ in $(seq 1 30); do
  if hyprctl dispatch dpms on >/dev/null 2>&1; then
    dpms_ok=1
    break
  fi
  sleep 0.1
done

if [[ "$dpms_ok" == "1" ]]; then
  exit 0
fi
exit 0
