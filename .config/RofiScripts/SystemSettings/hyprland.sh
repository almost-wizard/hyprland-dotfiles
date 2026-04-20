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
		" Windows and Workspaces" \
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
   "󱓞 Autostart") code ~/.config/hypr/hyprconfigs/hyprautostart.conf ;;
   "󰪫 Environment") code ~/.config/hypr/hyprconfigs/hyprenvironment.conf ;;
   "󰍽 Input") code ~/.config/hypr/hyprconfigs/hyprinput.conf ;;
   "󰌌 Keybindings") code ~/.config/hypr/hyprconfigs/hyprkeybinds.conf ;;
   " Look and Feel") code ~/.config/hypr/hyprconfigs/hyprlookandfeel.conf ;;
   "󰍹 Monitors") code ~/.config/hypr/hyprconfigs/hyprmonitors.conf ;;
   " Permissions") code ~/.config/hypr/hyprconfigs/hyprpermissions.conf ;;
   " Programs") code ~/.config/hypr/hyprconfigs/hyprprograms.conf ;;
   " Plugins") code ~/.config/hypr/hyprconfigs/hyprplugins.conf ;;
   " Windows and Workspaces") code ~/.config/hypr/hyprconfigs/hyprwindowsandworkspaces.conf ;;
   "󰥛 Animations (Variables!)") code ~/.config/hypr/hyprconfigs/hypranimations.conf ;;
   "󰘇 Decoration (Variables!)") code ~/.config/hypr/hyprconfigs/hyprdecoration.conf ;;
   *) exit 1 ;;
esac
