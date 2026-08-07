#!/usr/bin/env bash

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"󰐃 Save window layout" \
		"󰆴 Delete window layout" \
		"󰏫 Edit window layouts" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" \
			-kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" \
			-kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/Tools.sh
	exit 0
fi

case "$chosen" in
	"󰐃 Save window layout") ~/.config/hypr/scripts/save_window_state.sh ;;
	"󰆴 Delete window layout") ~/.config/hypr/scripts/save_window_state.sh --delete ;;
	"󰏫 Edit window layouts") kitty -e sh -lc "${EDITOR:-micro} $HOME/hyprland-dotfiles/.config/hypr/lua/windows-local.lua" ;;
	*) exit 1 ;;
esac
