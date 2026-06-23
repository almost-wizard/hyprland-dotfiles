#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			"󰌧 Select Wallpaper" \
			" Random Wallpapers" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/WallpaperChanger/WM.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/Appearance.sh
	exit 0
fi

case "$chosen" in
   "󰌧 Select Wallpaper") ~/.config/RofiScripts/WallpaperChanger/wall.sh ;;
   " Random Wallpapers") ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh ;;
   *) exit 1 ;;
esac
