#! /bin/sh

GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_DIR="$HOME/.config/gtk-4.0"
QT5CT_CONF="$HOME/.config/qt5ct/qt5ct.conf"
QT6CT_CONF="$HOME/.config/qt6ct/qt6ct.conf"

set_gtk3_key() {
	key="$1"
	value="$2"

	if grep -q "^${key}=" "$GTK3_SETTINGS" 2>/dev/null; then
		sed -i "s|^${key}=.*|${key}=${value}|" "$GTK3_SETTINGS"
	else
		printf "%s=%s\n" "$key" "$value" >> "$GTK3_SETTINGS"
	fi
}

set_ini_key() {
	file="$1"
	key="$2"
	value="$3"

	if grep -q "^${key}=" "$file" 2>/dev/null; then
		sed -i "s|^${key}=.*|${key}=${value}|" "$file"
	else
		printf "%s=%s\n" "$key" "$value" >> "$file"
	fi
}

mkdir -p "$HOME/.config/gtk-3.0" "$GTK4_DIR"
[ -f "$GTK3_SETTINGS" ] || printf "[Settings]\n" > "$GTK3_SETTINGS"
grep -q "^\[Settings\]" "$GTK3_SETTINGS" 2>/dev/null || sed -i '1i[Settings]' "$GTK3_SETTINGS"

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
set_gtk3_key "gtk-theme-name" "adw-gtk3"
set_gtk3_key "gtk-application-prefer-dark-theme" "0"
set_ini_key "$QT5CT_CONF" "icon_theme" "breeze"
set_ini_key "$QT6CT_CONF" "icon_theme" "breeze"
if command -v gsettings >/dev/null 2>&1; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-light" >/dev/null 2>&1 || true
	gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3" >/dev/null 2>&1 || true
fi
printf "%s\n" "@import 'colors.css';" > "$GTK4_DIR/gtk.css"
printf "%s\n" "@import 'colors.css';" > "$GTK4_DIR/gtk-dark.css"

ln -sfn ~/.config/RofiScripts/Walls-light/wall.sh ~/.config/RofiScripts/WallpaperChanger/wall.sh
ln -sfn ~/.config/RofiScripts/Walls-light/wallrandom.sh ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh
matugen image ~/.config/RofiScripts/Walls-light/Wall -m light -t scheme-fidelity --contrast 0.45 --fallback-color grey
if [ -f "$HOME/.config/kitty/themes/Matugen.conf" ]; then
	cp "$HOME/.config/kitty/themes/Matugen.conf" "$HOME/.config/kitty/current-theme.conf"
fi
if command -v kitty >/dev/null 2>&1; then
	kitty @ --to unix:/tmp/kitty set-colors "$HOME/.config/kitty/themes/Matugen.conf" >/dev/null 2>&1 || true
	for socket in /tmp/kitty-*; do
		[ -S "$socket" ] || continue
		kitty @ --to "unix:$socket" set-colors "$HOME/.config/kitty/themes/Matugen.conf" >/dev/null 2>&1 || true
	done
fi
ln -sfn ~/.config/RofiScripts/Walls-light/Wall ~/.config/RofiScripts/WallpaperChanger/Wall

if [ -f "$HOME/.gemini/antigravity-cli/settings.json" ]; then
	sed -i 's/"colorScheme": *"dark"/"colorScheme": "light"/' "$HOME/.gemini/antigravity-cli/settings.json"
fi

ln -sfn ~/.config/RofiScripts/Dark-Light-Mode/Dark/dark.sh ~/.config/swaync/scripts/changetheme.sh
