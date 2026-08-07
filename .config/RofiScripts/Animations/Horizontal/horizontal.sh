#!/usr/bin/env bash

echo 'return "slide"' > ~/.config/colors/animation_style.lua
hyprctl reload >/dev/null 2>&1