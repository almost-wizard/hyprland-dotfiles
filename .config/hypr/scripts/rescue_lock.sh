#!/usr/bin/env bash
set -euo pipefail

uid="$(id -u)"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$uid}"

export XDG_RUNTIME_DIR="$runtime_dir"

hypr_pid="$(pgrep -xu "$USER" -n Hyprland || true)"
if [[ -n "$hypr_pid" && -r "/proc/$hypr_pid/environ" ]]; then
  while IFS='=' read -r key value; do
    case "$key" in
      HYPRLAND_INSTANCE_SIGNATURE|WAYLAND_DISPLAY)
        export "$key=$value"
        ;;
    esac
  done < <(tr '\0' '\n' < "/proc/$hypr_pid/environ")
fi

if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  sig_dir="$(find "$runtime_dir/hypr" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | tail -n 1 || true)"
  if [[ -n "$sig_dir" ]]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$sig_dir"
  fi
fi

if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  export WAYLAND_DISPLAY="wayland-1"
fi

pkill -xu "$USER" hyprlock 2>/dev/null || true
pkill -xu "$USER" hypridle 2>/dev/null || true

for _ in $(seq 1 30); do
  if hyprctl dispatch dpms on >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

hypridle >/dev/null 2>&1 &
disown || true

hyprlock >/dev/null 2>&1 &
disown || true
