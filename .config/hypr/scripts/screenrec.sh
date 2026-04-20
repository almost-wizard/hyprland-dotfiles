#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/screenrec"
PID_FILE="$STATE_DIR/pid"
META_FILE="$STATE_DIR/meta"
WAYBAR_SIGNAL="${WAYBAR_SIGNAL:-10}"
VIDEOS_DIR="${SCREENREC_DIR:-$HOME/Videos/Recordings}"
DEFAULT_FPS="${SCREENREC_FPS:-60}"

if ! mkdir -p "$STATE_DIR" 2>/dev/null; then
  STATE_DIR="/tmp/screenrec-${UID:-$(id -u)}"
  mkdir -p "$STATE_DIR"
fi

have() { command -v "$1" >/dev/null 2>&1; }

signal_waybar() {
  pkill -SIGRTMIN+"$WAYBAR_SIGNAL" -x waybar 2>/dev/null || true
}

notify() {
  if have notify-send; then
    notify-send "Screen Recorder" "$1"
  fi
}

open_recordings_dir() {
  mkdir -p "$VIDEOS_DIR"
  if have xdg-open; then
    setsid -f xdg-open "$VIDEOS_DIR" >/dev/null 2>&1 || notify "Failed to open: $VIDEOS_DIR"
  else
    notify "xdg-open is not installed"
  fi
}

is_recording() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

cleanup_state() {
  rm -f "$PID_FILE" "$META_FILE"
}

meta_get() {
  local key="$1"
  [[ -f "$META_FILE" ]] || return 1
  sed -n "s/^${key}=//p" "$META_FILE" | head -n1
}

write_meta() {
  local mode="$1"
  local file="$2"
  local started="$3"
  cat >"$META_FILE" <<EOF
mode=$mode
file=$file
started=$started
EOF
}

fmt_duration() {
  local s="$1"
  (( s < 0 )) && s=0
  printf "%02d:%02d" "$((s / 60))" "$((s % 60))"
}

choose_monitor_name() {
  local entries chosen name
  entries="$(hyprctl -j monitors 2>/dev/null \
    | jq -r '.[] | "\(.name)\t\(.width)x\(.height) @ \(.x),\(.y)"')"

  [[ -n "$entries" ]] || return 1

  if [[ "$(printf "%s\n" "$entries" | wc -l)" -eq 1 ]]; then
    name="$(printf "%s\n" "$entries" | cut -f1)"
  else
    chosen="$(printf "%s\n" "$entries" \
      | rofi -dmenu -i -p "Monitor" -config "$HOME/.config/RofiScripts/Recorder/R.rasi")" || return 1
    [[ -n "$chosen" ]] || return 1
    name="$(printf "%s" "$chosen" | cut -f1)"
  fi

  printf "%s\n" "$name"
}

start_recording() {
  local mode="$1"
  local target="$2"
  local stamp output pid started

  if ! have wf-recorder; then
    notify "wf-recorder is not installed"
    exit 1
  fi

  if is_recording; then
    notify "Recording is already running"
    exit 0
  fi

  mkdir -p "$VIDEOS_DIR"
  stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  output="$VIDEOS_DIR/${stamp}.mp4"
  started="$(date +%s)"

  if [[ "$mode" == "monitor" ]]; then
    wf-recorder -o "$target" -f "$output" -r "$DEFAULT_FPS" >/dev/null 2>&1 &
  else
    wf-recorder -g "$target" -f "$output" -r "$DEFAULT_FPS" >/dev/null 2>&1 &
  fi
  pid="$!"

  echo "$pid" >"$PID_FILE"
  write_meta "$mode" "$output" "$started"
  signal_waybar
}

stop_recording() {
  local pid file
  if ! is_recording; then
    cleanup_state
    signal_waybar
    notify "No active recording"
    exit 0
  fi

  pid="$(cat "$PID_FILE")"
  file="$(meta_get file || true)"

  kill -INT "$pid" 2>/dev/null || true
  for _ in $(seq 1 40); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done

  cleanup_state
  signal_waybar
  if [[ -n "${file:-}" ]]; then
    notify "Saved: $(basename "$file")"
  else
    notify "Recording stopped"
  fi
}

status_json() {
  local text tooltip class started now elapsed

  if is_recording; then
    started="$(meta_get started || echo 0)"
    now="$(date +%s)"
    elapsed=$((now - started))
    text="󰑊 $(fmt_duration "$elapsed")"
    class="recording"
    tooltip="Recording... Left click: stop. Right click: menu."
  else
    text=""
    class="idle"
    tooltip=""
  fi

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
}

start_by_mode() {
  local mode="$1" target=""
  case "$mode" in
    region) target="$(slurp 2>/dev/null || true)" ;;
    monitor) target="$(choose_monitor_name)" ;;
    *)
      echo "Unknown mode: $mode" >&2
      exit 2
      ;;
  esac

  if [[ -z "${target:-}" ]]; then
    notify "Selection cancelled"
    exit 1
  fi

  start_recording "$mode" "$target"
}

case "${1:-}" in
  --start)
    shift
    [[ -n "${1:-}" ]] || { echo "Usage: $0 --start <mode>" >&2; exit 2; }
    start_by_mode "$1"
    ;;
  --stop)
    stop_recording
    ;;
  --toggle)
    if is_recording; then
      stop_recording
    else
      start_by_mode "region"
    fi
    ;;
  --waybar)
    status_json
    ;;
  --waybar-watch)
    while true; do
      status_json
      sleep 1
    done
    ;;
  --waybar-click)
    if is_recording; then
      stop_recording
    else
      ~/.config/RofiScripts/Recorder/Recorder.sh
    fi
    ;;
  --is-recording)
    if is_recording; then
      exit 0
    else
      exit 1
    fi
    ;;
  --open-dir)
    open_recordings_dir
    ;;
  *)
    cat >&2 <<EOF
Usage:
  $0 --start <region|monitor>
  $0 --stop
  $0 --toggle
  $0 --is-recording
  $0 --open-dir
  $0 --waybar
  $0 --waybar-watch
  $0 --waybar-click
EOF
    exit 2
    ;;
esac
