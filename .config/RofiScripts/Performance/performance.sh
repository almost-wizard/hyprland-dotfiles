#! /bin/sh
set -u

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-dotfiles"
refresh_state_file="$state_dir/perf_refresh_hz.state"

mkdir -p "$state_dir"

notify() {
  notify-send "Performance" "$1"
}

detect_refresh_hz() {
  hz=""
  if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    hz="$(hyprctl -j monitors 2>/dev/null \
      | jq -r '([.[] | select(.focused == true)][0] // .[0]) | (.refreshRate // .refresh_rate // empty)' 2>/dev/null \
      | head -n1 | sed 's/\..*//')"
  fi
  if [ -z "$hz" ]; then
    cur="$("$HOME/.config/hypr/scripts/power_refresh.sh" --status 2>/dev/null || true)"
    hz="$(printf "%s" "$cur" | sed -n 's/.*\([0-9][0-9]*\)Hz.*/\1/p' | head -n1)"
  fi
  if [ -z "$hz" ] && [ -f "$refresh_state_file" ]; then
    hz="$(cat "$refresh_state_file" 2>/dev/null || true)"
  fi
  printf "%s" "$hz"
}

next_refresh_label() {
  current_hz="$(detect_refresh_hz)"
  if [ -n "$current_hz" ] && [ "$current_hz" -ge 90 ] 2>/dev/null; then
    target_hz="60"
  else
    target_hz="90"
  fi
  [ -z "$current_hz" ] && current_hz="?"
  echo "󰖟 Toggle ${current_hz}Hz → ${target_hz}Hz"
}

refresh_item="$(next_refresh_label)"
set_perf_item="󰓅 Set Power Mode: performance"
set_bal_item="󰾅 Set Power Mode: balanced"
set_save_item="󰾆 Set Power Mode: power-saver"

selected_index="$(
  printf "%s\n" \
    "$back_label" \
    "$refresh_item" \
    "$set_perf_item" \
    "$set_bal_item" \
    "$set_save_item" |
    rofi -dmenu -i -format i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" \
      -theme-str 'window { width: 23em; }' \
      -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" \
      -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)"
rc=$?

if [ "$rc" -eq 10 ] || [ "$selected_index" = "0" ]; then
  ~/.config/RofiScripts/Launcher/System.sh
  exit 0
fi

if [ "$selected_index" = "1" ]; then
  current_hz="$(detect_refresh_hz)"
  if [ -n "$current_hz" ] && [ "$current_hz" -ge 90 ] 2>/dev/null; then
    target_hz="60"
  else
    target_hz="90"
  fi
  "$HOME/.config/hypr/scripts/power_refresh.sh" --set "$target_hz"
  cur="$("$HOME/.config/hypr/scripts/power_refresh.sh" --status 2>/dev/null || true)"
  hz="$(printf "%s" "$cur" | sed -n 's/.*\([0-9][0-9]*\)Hz.*/\1/p' | head -n1)"
  if [ -n "$hz" ]; then
    printf "%s\n" "$hz" > "$refresh_state_file"
  else
    printf "%s\n" "$target_hz" > "$refresh_state_file"
  fi
  [ -n "$cur" ] && notify "$cur"
  exit 0
fi

if [ "$selected_index" = "2" ] || [ "$selected_index" = "3" ] || [ "$selected_index" = "4" ]; then
  command -v powerprofilesctl >/dev/null 2>&1 || exit 1

  target=""
  case "$selected_index" in
    2) target="performance" ;;
    3) target="balanced" ;;
    4) target="power-saver" ;;
  esac

  powerprofilesctl set "$target" >/dev/null 2>&1 || exit 1
  exit 0
fi

exit 1
