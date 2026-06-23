#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_id="0"
back_label="← Back"

clips="$(cliphist list)"
selected_row=0
menu="$(printf "%s\t%s\n" "$back_id" "$back_label")"
if [ -n "$clips" ]; then
	selected_row=1
	menu="$(printf "%s\t%s\n%s" "$back_id" "$back_label" "$clips")"
fi

open_launcher() {
	if command -v hyprctl >/dev/null 2>&1; then
		hyprctl dispatch exec "$HOME/.config/RofiScripts/Launcher/Capture.sh" >/dev/null 2>&1
	else
		setsid -f "$HOME/.config/RofiScripts/Launcher/Capture.sh" >/dev/null 2>&1
	fi
}

chosen_index=$(
	{
		printf "%s" "$menu"
	} | rofi -dmenu -format i -selected-row "$selected_row" -display-columns 2 -config "$HOME/.config/RofiScripts/Clipboard/CB.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	open_launcher
	exit 0
fi

[ -z "$chosen_index" ] && exit 0

case "$chosen_index" in
	*[!0-9]*)
		exit 1
		;;
esac

if [ "$chosen_index" -eq 0 ]; then
	open_launcher
	exit 0
fi

line_number=$((chosen_index + 1))
chosen_line="$(printf "%s" "$menu" | sed -n "${line_number}p")"
[ -z "$chosen_line" ] && exit 0
printf "%s" "$chosen_line" | cliphist decode | wl-copy
