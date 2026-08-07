#!/usr/bin/env bash

echo 'return "slidevert"' > ~/.config/colors/animation_style.lua
hyprctl reload >/dev/null 2>&1