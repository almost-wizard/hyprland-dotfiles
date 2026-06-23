#! /bin/sh

DIR="$HOME/Pictures/Wallpapers/Walls-light/Walls"
LAST_WALLPAPER="$HOME/.config/RofiScripts/Walls-light/Last_Wallpaper.txt"

count=$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
if [ "$count" -eq 0 ]; then
    notify-send "Wallpaper randomizer" "No wallpapers found in: $DIR"
    exit 1
fi

last=""
[ -f "$LAST_WALLPAPER" ] && last=$(cat "$LAST_WALLPAPER")

selected=$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | shuf -n 1)
if [ -z "$selected" ]; then
    notify-send "Wallpaper randomizer" "Failed to pick a wallpaper from: $DIR"
    exit 1
fi

if [ "$count" -gt 1 ] && [ -n "$last" ]; then
    while [ "$selected" = "$last" ]; do
        selected=$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | shuf -n 1)
        if [ -z "$selected" ]; then
            notify-send "Wallpaper randomizer" "Failed to pick a wallpaper from: $DIR"
            exit 1
        fi
    done
fi

matugen image "$selected" -m light -t scheme-fidelity --contrast 0.45 --fallback-color grey

ln -sfn "$selected" ~/.config/RofiScripts/Walls-light/Wall
ln -sfn "$selected" ~/.config/RofiScripts/WallpaperChanger/Wall
echo "$selected" > "$LAST_WALLPAPER"
~/.config/hypr/scripts/sync-kbd-rgb.sh || true
