#!/usr/bin/env bash

set -euo pipefail

config_file="/home/alex/hyprland-dotfiles/.config/hypr/hyprconfigs/hyprwindows-local.conf"
mode="${1:-save}"

regex_escape() {
  printf '%s' "$1" | sed -e 's/[][(){}.^$*+?|\\]/\\&/g'
}

notify() {
  local msg="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprland" "$msg"
  else
    printf '%s\n' "$msg" >&2
  fi
}

active_json="$(hyprctl -j activewindow)"
if [[ -z "$active_json" || "$active_json" == "{}" ]]; then
  notify "No active window to save."
  exit 1
fi

class="$(printf '%s' "$active_json" | jq -r '.class // empty')"
initial_title="$(printf '%s' "$active_json" | jq -r '.initialTitle // empty')"
title="$(printf '%s' "$active_json" | jq -r '.title // empty')"
floating="$(printf '%s' "$active_json" | jq -r '.floating // false')"
width="$(printf '%s' "$active_json" | jq -r '.size[0] // 0')"
height="$(printf '%s' "$active_json" | jq -r '.size[1] // 0')"
pos_x="$(printf '%s' "$active_json" | jq -r '.at[0] // 0')"
pos_y="$(printf '%s' "$active_json" | jq -r '.at[1] // 0')"

if [[ -z "$class" ]]; then
  notify "Active window has no class; nothing was saved."
  exit 1
fi

if [[ "$floating" != "true" ]]; then
  notify "Only floating windows can be saved."
  exit 1
fi

class_regex="$(regex_escape "$class")"
matcher="match:class ^(${class_regex})$"
matcher_label="class=${class}"

if [[ -n "$initial_title" && "$initial_title" != "$class" && "$initial_title" != "$title" ]]; then
  initial_title_regex="$(regex_escape "$initial_title")"
  matcher="${matcher}, match:initial_title ^(${initial_title_regex})$"
  matcher_label="${matcher_label} initial_title=${initial_title}"
fi

rule_key="$(printf '%s' "$matcher" | sha1sum | cut -d' ' -f1)"
begin_marker="# BEGIN AUTORULE ${rule_key}"
end_marker="# END AUTORULE ${rule_key}"
timestamp="$(date -Iseconds)"

tmp_file="$(mktemp)"

if [[ -f "$config_file" ]]; then
  awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$config_file" >"$tmp_file"
else
  cat >"$tmp_file" <<'EOF'
#############################
### LOCAL WINDOW LAYOUTS ###
#############################

# This file is managed by ~/.config/hypr/scripts/save_window_state.sh.
# Generated rules are appended below and reloaded automatically.
EOF
fi

if [[ "$mode" == "--delete" ]]; then
  mv "$tmp_file" "$config_file"
  hyprctl reload >/dev/null
  notify "Deleted saved window state for ${class}."
  exit 0
fi

if [[ "$mode" != "save" ]]; then
  rm -f "$tmp_file"
  notify "Unknown mode: ${mode}"
  exit 1
fi

{
  printf '\n%s\n' "$begin_marker"
  printf '# Saved %s for %s\n' "$timestamp" "$matcher_label"
  printf 'windowrule = float 1, %s\n' "$matcher"
  if [[ "$width" -gt 0 && "$height" -gt 0 ]]; then
    printf 'windowrule = size %s %s, %s\n' "$width" "$height" "$matcher"
  fi
  printf 'windowrule = move %s %s, %s\n' "$pos_x" "$pos_y" "$matcher"
  printf '%s\n' "$end_marker"
} >>"$tmp_file"

mv "$tmp_file" "$config_file"
hyprctl reload >/dev/null
notify "Saved window state for ${class}."
