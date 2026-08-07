---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",

        follow_mouse = 1,
        force_no_accel = true,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Per-device configs (use hl.device() instead of device = {} in hl.config)
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name = "dualsense-wireless-controller-touchpad",
    enabled = false,
})

hl.device({
    name = "sony-interactive-entertainment-dualsense-wireless-controller-touchpad",
    enabled = false,
})

hl.device({
    name = "opentabletdriver-virtual-artist-tablet",
    output = "eDP-1",
})

hl.device({
    name = "wacom-one-by-wacom-s-pen",
    output = "eDP-1",
})
