#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

DIR="$HOME/Pictures/Wallpapers/Walls-dark/Walls"

selected=$(
	{
		ls "$DIR" | while read -r A; do
			echo -en "$A\x00icon\x1f$DIR/$A\n"
		done
		} | rofi -dmenu -i -config "$HOME/.config/RofiScripts/WallpaperChanger/WC.rasi" \
			-ml-row-left ScrollUp -ml-row-right ScrollDown -ml-row-up ScrollLeft -ml-row-down ScrollRight
	)
rc=$?

if [ "$rc" -eq 10 ]; then
	~/.config/RofiScripts/WallpaperChanger/WallMenu.sh
	exit 0
fi
[ -z "$selected" ] && exit 0
matugen image "$DIR/$selected" -m dark -t scheme-fidelity --fallback-color grey
ln -sfn "$DIR/$selected" ~/.config/RofiScripts/Walls/Wall
ln -sfn "$DIR/$selected" ~/.config/RofiScripts/WallpaperChanger/Wall
~/.config/hypr/scripts/sync-kbd-rgb.sh || true

swaync-client -rs
