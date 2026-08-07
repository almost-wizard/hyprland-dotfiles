#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"󱓞 Autostart" \
		"󰪫 Environment" \
		"󰍽 Input" \
		"󰌌 Keybindings" \
		" Look and Feel" \
		"󰍹 Monitors" \
		" Permissions" \
		" Programs" \
		" Plugins" \
		" Window Rules" \
		"󱂬 Auto Window Rules" \
		"󰥛 Animations (Variables!)" \
		"󰘇 Decoration (Variables!)" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S_hyprland.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/System.sh
	exit 0
fi

case "$chosen" in
   "󱓞 Autostart") code ~/.config/hypr/lua/autostart.lua ;;
   "󰪫 Environment") code ~/.config/hypr/lua/environment.lua ;;
   "󰍽 Input") code ~/.config/hypr/lua/input.lua ;;
   "󰌌 Keybindings") code ~/.config/hypr/lua/keybinds.lua ;;
   " Look and Feel") code ~/.config/hypr/lua/lookandfeel.lua ;;
   "󰍹 Monitors") code ~/.config/hypr/lua/monitors.lua ;;
   " Permissions") code ~/.config/hypr/lua/permissions.lua ;;
   " Programs") code ~/.config/hypr/lua/programs.lua ;;
   " Plugins") code ~/.config/hypr/hyprland.lua ;;
   " Window Rules") code ~/.config/hypr/lua/windowsandworkspaces.lua ;;
   "󱂬 Auto Window Rules") code ~/.config/hypr/lua/windows-local.lua ;;
   "󰥛 Animations (Variables!)") code ~/.config/hypr/lua/lookandfeel.lua ;;
   "󰘇 Decoration (Variables!)") code ~/.config/hypr/lua/lookandfeel.lua ;;
   *) exit 1 ;;
esac
