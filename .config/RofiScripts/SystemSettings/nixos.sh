#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			" Configuration" \
			"󰋜 Home Manager" \
			" Flake" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/System.sh
	exit 0
fi

case "$chosen" in
   " Configuration") code ~/hyprland-dotfiles/NixOS/configuration.nix ;;
   "󰋜 Home Manager") code ~/hyprland-dotfiles/NixOS/home.nix ;;
   " Flake") code ~/hyprland-dotfiles/NixOS/flake.nix ;;
   *) exit 1 ;;
esac
