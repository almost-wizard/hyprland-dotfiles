#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <app>" >&2
  exit 1
fi

app="$1"
class="tui-toggle-${app}"
title="TUI_TOGGLE_${app^^}"

addr="$(hyprctl -j clients | jq -r --arg class "$class" '
  map(select(.class == $class or .initialClass == $class)) | .[0].address // empty
')"

if [[ -n "$addr" ]]; then
  active_addr="$(hyprctl -j activewindow | jq -r '.address // empty')"
  if [[ "$active_addr" == "$addr" ]]; then
    hyprctl dispatch 'hl.dsp.window.close({ window = "address:'"${addr}"'" })' >/dev/null
  else
    hyprctl dispatch 'hl.dsp.focus({ window = "address:'"${addr}"'" })' >/dev/null
  fi
  exit 0
fi

hyprctl dispatch 'hl.dsp.exec_cmd("kitty --class '"${class}"' --title '"${title}"' '"${app}"'", { float = true, size = { 879, 879 }, center = true })' >/dev/null
