#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

chosen=$(
	printf "%s\n" \
		" Apps" \
		" Appearance" \
		" System" \
		"󰴉 Capture" \
		"󰃬 Tools" \
		"󰐥 Session" |
			rofi -dmenu -i -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	exit 0
fi

case "$chosen" in
   " Apps") rofi -show drun -ml-row-left ScrollUp -ml-row-right ScrollDown -ml-row-up ScrollLeft -ml-row-down ScrollRight ;;
   " Appearance") ~/.config/RofiScripts/Launcher/Appearance.sh ;;
   " System") ~/.config/RofiScripts/Launcher/System.sh ;;
   "󰴉 Capture") ~/.config/RofiScripts/Launcher/Capture.sh ;;
   "󰃬 Tools") ~/.config/RofiScripts/Launcher/Tools.sh ;;
   "󰐥 Session") ~/.config/RofiScripts/Launcher/Session.sh ;;
   *) exit 1 ;;
esac
