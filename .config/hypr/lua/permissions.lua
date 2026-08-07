-----------------------
----- PERMISSIONS -----
-----------------------

hl.config({
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
