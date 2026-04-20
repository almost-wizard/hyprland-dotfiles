#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			"󰃠 Brightness" \
			"󰥔 Idle Timers" \
			"󰕾 Sound" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/SystemSettings/hyprland.sh
	exit 0
fi

case "$chosen" in
	"󰃠 Brightness") code ~/.config/hypr/scripts/brightness_control.sh ;;
	"󰥔 Idle Timers") code ~/.config/hypr/hypridle.conf ;;
	"󰕾 Sound") code ~/.config/hypr/scripts/volume_control.sh ;;
	*) exit 1 ;;
esac
