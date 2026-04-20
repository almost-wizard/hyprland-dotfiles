#! /bin/sh

~/.config/RofiScripts/Animations/Horizontal/horizontal.sh
~/.config/RofiScripts/Rounding/RoundingThemes/20px/round.sh
hyprctl reload
ln -sf ~/.config/RofiScripts/Waybars/WaybarThemes/bar/config.jsonc ~/.config/waybar/config.jsonc
ln -sf ~/.config/RofiScripts/Waybars/WaybarThemes/bar/style.css ~/.config/waybar/style.css
ln -sf ~/.config/RofiScripts/Waybars/WaybarThemes/bar/modules.jsonc ~/.config/waybar/modules.jsonc
pkill -x waybar 2>/dev/null || true
pkill -x .waybar-wrapped 2>/dev/null || true
waybar -l off -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
