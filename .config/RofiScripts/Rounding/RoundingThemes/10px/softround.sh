#!/usr/bin/env bash

echo "return 10" > ~/.config/colors/rounding.lua
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/10px/rofiradius.rasi ~/.config/colors/rofiradius.rasi
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/10px/swayncradius.css ~/.config/colors/swayncradius.css
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/10px/waybarradius.css ~/.config/colors/waybarradius.css
hyprctl reload >/dev/null 2>&1
swaync-client -R >/dev/null 2>&1
swaync-client -rs >/dev/null 2>&1
pkill -SIGUSR2 waybar >/dev/null 2>&1 || true