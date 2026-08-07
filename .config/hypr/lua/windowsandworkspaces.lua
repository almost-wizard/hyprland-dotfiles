----------------------------------
---- WINDOWS AND WORKSPACES ----
----------------------------------

-- Workspace rules
hl.workspace_rule({ workspace = "1",  monitor = "eDP-1",   default = true, persistent = true })
hl.workspace_rule({ workspace = "2",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "4",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "5",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "6",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "7",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "8",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })

hl.workspace_rule({ workspace = "11", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "12", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "13", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "14", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "15", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "16", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "17", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "18", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "19", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "20", monitor = "HDMI-A-1" })

hl.workspace_rule({ workspace = "name:Windows", monitor = "eDP-1" })

-- Window rules
hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "portal-gtk-float",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "pip-window",
    match = { initial_title = "Picture-in-Picture" },
    float = true,
    pin = true,
    move = { 1034, 747 },
    size = { 630, 356 },
})

-- Opacity rules
hl.window_rule({ match = { class = "code" },                  opacity = "0.95 0.85" })
hl.window_rule({ match = { class = "org.telegram.desktop" },  opacity = "0.95 0.85" })
hl.window_rule({ match = { initial_title = "yandex-music" },  opacity = "0.80 0.85" })
hl.window_rule({ match = { class = "obsidian" },              opacity = "0.95 0.90" })

-- Idle inhibit for all fullscreen windows
hl.window_rule({ match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Special scratchpad apps
hl.window_rule({
    match = { class = "Throne" },
    workspace = "special:magic silent",
    float = true,
    opacity = "0.85 0.75",
    size = { 800, 600 },
    move = { 105, 285 },
})

hl.window_rule({
    match = { class = "AmneziaVPN" },
    workspace = "special:magic silent",
    float = true,
    opacity = "0.85 0.75",
    size = { 509, 752 },
    move = { 1052, 219 },
})

-- KTalk always on HDMI workspace
hl.window_rule({ match = { class = "ktalk" }, workspace = "11" })

-- Dragon-drop (pinned and floating)
hl.window_rule({ match = { class = "dragon" }, float = true, pin = true })
hl.window_rule({ match = { title = "dragon" }, float = true, pin = true })

-- Include local user-saved window rules if present
local home = os.getenv("HOME") or "/home/alex"
local local_rules_file = home .. "/.config/hypr/lua/windows-local.lua"
local f = io.open(local_rules_file, "r")
if f then
    f:close()
    pcall(dofile, local_rules_file)
end
