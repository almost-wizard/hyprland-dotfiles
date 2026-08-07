-- Hyprland Lua Main Configuration File
-- Designed for Hyprland 0.55+

local home = os.getenv("HOME") or "/home/alex"
package.path = home .. "/.config/hypr/?.lua;" .. home .. "/.config/hypr/?/init.lua;" .. package.path

require("lua.monitors")
require("lua.environment")
require("lua.permissions")
require("lua.autostart")
require("lua.lookandfeel")
require("lua.input")
require("lua.keybinds")
require("lua.windowsandworkspaces")
