------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "2520x1680@90",
    position = "0x0",
    scale    = 1.5,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100",
    position = "-120x-1080",
    scale    = 1.0,
})
