#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		" Theme" \
		" Wallpapers" \
		"󰘇 Window Shape" \
		"󰥛 Animation Style" \
		" Waybar" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" \
			-kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" \
			-kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/Launcher.sh
	exit 0
fi

case "$chosen" in
	" Theme") ~/.config/RofiScripts/Dark-Light-Mode/DLmode.sh ;;
	" Wallpapers") ~/.config/RofiScripts/WallpaperChanger/WallMenu.sh ;;
	"󰘇 Window Shape") ~/.config/RofiScripts/Rounding/Rounding.sh ;;
	"󰥛 Animation Style") ~/.config/RofiScripts/Animations/Animations.sh ;;
	" Waybar") ~/.config/RofiScripts/Waybars/Waybar.sh ;;
	*) exit 1 ;;
esac
