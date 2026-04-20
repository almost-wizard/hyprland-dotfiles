#! /bin/sh

GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_DIR="$HOME/.config/gtk-4.0"

set_gtk3_key() {
	key="$1"
	value="$2"

	if grep -q "^${key}=" "$GTK3_SETTINGS" 2>/dev/null; then
		sed -i "s|^${key}=.*|${key}=${value}|" "$GTK3_SETTINGS"
	else
		printf "%s=%s\n" "$key" "$value" >> "$GTK3_SETTINGS"
	fi
}

mkdir -p "$HOME/.config/gtk-3.0" "$GTK4_DIR"
[ -f "$GTK3_SETTINGS" ] || printf "[Settings]\n" > "$GTK3_SETTINGS"
grep -q "^\[Settings\]" "$GTK3_SETTINGS" 2>/dev/null || sed -i '1i[Settings]' "$GTK3_SETTINGS"

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
set_gtk3_key "gtk-theme-name" "adw-gtk3-dark"
set_gtk3_key "gtk-application-prefer-dark-theme" "1"
if command -v gsettings >/dev/null 2>&1; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" >/dev/null 2>&1 || true
	gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark" >/dev/null 2>&1 || true
fi
printf "%s\n" "@import 'colors.css';" > "$GTK4_DIR/gtk.css"
printf "%s\n" "@import 'colors.css';" > "$GTK4_DIR/gtk-dark.css"

ln -sfn ~/.config/RofiScripts/Walls/wall.sh ~/.config/RofiScripts/WallpaperChanger/wall.sh
ln -sfn ~/.config/RofiScripts/Walls/wallrandom.sh ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh
matugen image ~/.config/RofiScripts/Walls/Wall -m dark -t scheme-fidelity --fallback-color grey
ln -sfn ~/.config/RofiScripts/Walls/Wall ~/.config/RofiScripts/WallpaperChanger/Wall

ln -sfn ~/.config/RofiScripts/Dark-Light-Mode/Light/light.sh ~/.config/swaync/scripts/changetheme.sh
