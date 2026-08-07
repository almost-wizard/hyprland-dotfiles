-------------------
---- KEYBINDS ----
-------------------

local programs = require("lua.programs")
local workspaces = require("lua.workspaces")
local home = os.getenv("HOME") or "/home/alex"

-- App launches & actions
hl.bind("SUPER + Q", hl.dsp.exec_cmd(programs.terminal))
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + V", function()  -- pin + bring to top
    hl.dispatch(hl.dsp.window.pin())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
hl.bind("SUPER + R", hl.dsp.exec_cmd(programs.menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + X", hl.dsp.window.center())
hl.bind("SUPER + Z", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("pkill -x rofi || pkill -x .rofi-wrapped || " .. home .. "/.config/RofiScripts/Launcher/Launcher.sh"))
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("qs ipc -p ~/.config/quickshell/overview call overview toggle"))

-- Utility scripts
hl.bind("Print",                     hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot_active_monitor.sh"))
hl.bind("SUPER + SHIFT + S",         hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot_region.sh"))
hl.bind("SUPER + CTRL + SHIFT + S",  hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot_region.sh --repeat"))
hl.bind("SUPER + SHIFT + R",         hl.dsp.exec_cmd(home .. "/.config/RofiScripts/Recorder/Recorder.sh"))
hl.bind("SUPER + SHIFT + T",         hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/ocr.sh"))
hl.bind("SUPER + SHIFT + E",         hl.dsp.exec_cmd(home .. "/.config/RofiScripts/Emoji/Emoji.sh"))
hl.bind("SUPER + SHIFT + P",         hl.dsp.exec_cmd("hyprpicker -a -l"))
hl.bind("SUPER + B",                 hl.dsp.exec_cmd("pkill hyprsunset || hyprsunset -t 5400"))
hl.bind("SUPER + SHIFT + F",         hl.dsp.window.fullscreen())
hl.bind("SUPER + T",                 hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + Delete",            hl.dsp.exec_cmd("hyprctl kill"))
hl.bind("ALT + F4",                  hl.dsp.exec_cmd(home .. "/.config/RofiScripts/powermenu/powermenu.sh"))
hl.bind("SUPER + SHIFT + C",         hl.dsp.exec_cmd(home .. "/.config/RofiScripts/Clipboard/Clipboard.sh"))
hl.bind("SUPER + SHIFT + N",         hl.dsp.exec_cmd("swaync-client -C"))
hl.bind("SUPER + N",                 hl.dsp.exec_cmd("swaync-client -d"))
hl.bind("SUPER + CTRL + N",          hl.dsp.exec_cmd("swaync-client -t"))
hl.bind("SUPER + CTRL + W",          hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_tui.sh nmtui"))
hl.bind("SUPER + CTRL + B",          hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_tui.sh bluetui"))

-- Wallpaper Changer
hl.bind("SUPER + CTRL + space", hl.dsp.exec_cmd(home .. "/.config/RofiScripts/WallpaperChanger/wall.sh"))

-- Focus (Normal window focus outside submap)
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

-- Resize (with repeating flag)
local repeat_flag = { repeating = true }
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x =  100, y =    0, relative = true }), repeat_flag)
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = -100, y =    0, relative = true }), repeat_flag)
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x =    0, y = -100, relative = true }), repeat_flag)
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x =    0, y =  100, relative = true }), repeat_flag)

-- Switch Workspaces (1..10 only)
for i = 1, 9 do
    hl.bind("SUPER + " .. tostring(i),         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Grid Workspace Navigation (2 rows x 5 columns: 1-5 top, 6-10 bottom)
hl.bind("SUPER + A",         workspaces.focus_grid_relative(-1))
hl.bind("SUPER + D",         workspaces.focus_grid_relative(1))
hl.bind("SUPER + SHIFT + A", workspaces.move_active_window_grid_relative(-1))
hl.bind("SUPER + SHIFT + D", workspaces.move_active_window_grid_relative(1))
hl.bind("SUPER + S",         workspaces.focus_grid_relative(5))
hl.bind("SUPER + SHIFT + S", workspaces.move_active_window_grid_relative(5))

-- Navigation only by opened workspaces (e-1 / e+1)
hl.bind("SUPER + CTRL + A",         workspaces.focus_open_relative(-1))
hl.bind("SUPER + CTRL + D",         workspaces.focus_open_relative(1))
hl.bind("SUPER + CTRL + SHIFT + A", workspaces.move_active_window_open_relative(-1))
hl.bind("SUPER + CTRL + SHIFT + D", workspaces.move_active_window_open_relative(1))

-- Window moving
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))

-- Special workspace
hl.bind("SUPER + W",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse scroll workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window move/resize
local mouse_flags = { mouse = true }
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   mouse_flags)
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), mouse_flags)

-- Laptop multimedia keys (repeat + locked)
local lock_repeat = { repeating = true, locked = true }
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_control.sh up"),       lock_repeat)
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_control.sh down"),     lock_repeat)
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_control.sh mute"),     lock_repeat)
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_control.sh mic-mute"), lock_repeat)
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness_control.sh up"),   lock_repeat)
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness_control.sh down"), lock_repeat)

-- Playerctl
hl.bind("SUPER + bracketleft",          hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + bracketright",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("SUPER + backslash",            hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER + SHIFT + bracketleft",  hl.dsp.exec_cmd("playerctl position 10-"))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.exec_cmd("playerctl position 10+"))

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
