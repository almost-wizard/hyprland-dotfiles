-------------------
---- AUTOSTART ----
-------------------

local home = os.getenv("HOME") or "/home/alex"

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
    -- Launch apps into special:magic workspace silently
    hl.dispatch(hl.dsp.exec_cmd("AmneziaVPN", { workspace = "special:magic", no_initial_focus = true }))
    hl.dispatch(hl.dsp.exec_cmd("Throne",     { workspace = "special:magic", no_initial_focus = true }))
    -- Background daemons & utils
    hl.exec_cmd("qs -p ~/.config/quickshell/overview -n")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("swaync")
    hl.exec_cmd(home .. "/.config/hypr/scripts/waybar_start.sh")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1")
end)
