-----------------------
---- LOOK AND FEEL ----
-----------------------

local home = os.getenv("HOME") or "/home/alex"
local colors_path = home .. "/.config/colors/hyprcolors.lua"
local rounding_path = home .. "/.config/colors/rounding.lua"
local anim_style_path = home .. "/.config/colors/animation_style.lua"

local colors = {}
local color_file = io.open(colors_path, "r")
if color_file then
    color_file:close()
    local ok, res = pcall(dofile, colors_path)
    if ok and type(res) == "table" then
        colors = res
    end
end

-- Read dynamic rounding
local current_rounding = 20
local rounding_file = io.open(rounding_path, "r")
if rounding_file then
    rounding_file:close()
    local ok, res = pcall(dofile, rounding_path)
    if ok and type(res) == "number" then
        current_rounding = res
    end
end

-- Read dynamic workspace animation style (slide / slidevert)
local workspace_anim_style = "slide"
local anim_file = io.open(anim_style_path, "r")
if anim_file then
    anim_file:close()
    local ok, res = pcall(dofile, anim_style_path)
    if ok and type(res) == "string" then
        workspace_anim_style = res
    end
end

local active_border = colors["primary"] or "rgba(ffb59bff)"
local inactive_border = colors["background"] or "rgba(1a110eff)"

-- Curves definition
hl.curve("smoothFast",    { type = "bezier", points = { {0.4, 0}, {0.2, 1} } })
hl.curve("smoothSlow",    { type = "bezier", points = { {0.0, 0}, {0.2, 1} } })
hl.curve("easeInSleek",   { type = "bezier", points = { {0.55, 0}, {0.1, 1} } })
hl.curve("easeOutSleek",  { type = "bezier", points = { {0.1, 0}, {0.45, 1} } })
hl.curve("linearSlick",   { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("softGlide",     { type = "bezier", points = { {0.3, 0}, {0.3, 1} } })
hl.curve("gentleCurve",   { type = "bezier", points = { {0.25, 0.1}, {0.35, 0.95} } })

hl.config({
    general = {
        gaps_in = 10,
        gaps_out = 15,
        border_size = 2,
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
        resize_on_border = false,
        allow_tearing = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = current_rounding,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 10,
            render_power = 2,
            color = "rgba(00000099)",
            color_inactive = "rgba(00000077)",
            offset = { 0, 0 },
        },

        blur = {
            enabled = true,
            special = true,
            size = 3,
            passes = 2,
            noise = 0.03,
            popups = true,
            popups_ignorealpha = 0.45,
            contrast = 1.1,
            xray = false,
            new_optimizations = true,
            vibrancy = 0.3,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
        mfact = 0.55,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
})

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "smoothSlow" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "smoothFast" })
hl.animation({ leaf = "windows",       enabled = true, speed = 2.2,  bezier = "softGlide", style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 2.2,  bezier = "softGlide", style = "popin" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.2,  bezier = "easeOutSleek", style = "popin" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "easeInSleek" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "easeOutSleek" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "gentleCurve" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2.1,  bezier = "softGlide", style = "slide" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2.5,  bezier = "softGlide", style = "popin" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.5,  bezier = "easeOutSleek", style = "popin" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "easeInSleek" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "easeOutSleek" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2,    bezier = "softGlide", style = workspace_anim_style })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 2,    bezier = "softGlide", style = workspace_anim_style })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2,    bezier = "easeOutSleek", style = workspace_anim_style })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "gentleCurve" })
