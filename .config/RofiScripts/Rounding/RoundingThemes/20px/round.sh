#!/usr/bin/env bash

echo "return 20" > ~/.config/colors/rounding.lua
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/20px/rofiradius.rasi ~/.config/colors/rofiradius.rasi
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/20px/swayncradius.css ~/.config/colors/swayncradius.css
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/20px/waybarradius.css ~/.config/colors/waybarradius.css
hyprctl reload >/dev/null 2>&1
swaync-client -R >/dev/null 2>&1
swaync-client -rs >/dev/null 2>&1
pkill -SIGUSR2 waybar >/dev/null 2>&1 || true