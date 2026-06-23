#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

if ! command -v rofimoji >/dev/null 2>&1; then
	notify-send "Emoji picker" "rofimoji is not installed"
	exit 1
fi

rofi \
	-modi "emoji:rofimoji --action copy --prompt '󰞅 '" \
	-show emoji \
	-config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" \
	-lines 8 \
	-theme-str 'configuration { fixed-num-lines: true; } listview { lines: 8; } window { width: 24em; height: 82.5%; }' \
	-kb-move-char-back "" \
	-kb-move-char-forward "" \
	-kb-custom-1 "Left" \
	-kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
