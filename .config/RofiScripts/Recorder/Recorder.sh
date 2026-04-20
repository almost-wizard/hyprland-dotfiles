#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
open_folder_label="󰉋 Open Recordings Folder"
is_recording=false

if ~/.config/hypr/scripts/screenrec.sh --is-recording; then
  is_recording=true
fi

chosen=$(
  {
    printf "%s\n" "$back_label"

    if [ "$is_recording" = true ]; then
      printf "%s\n" "󰓛 Stop Recording"
    else
      printf "%s\n" "󰖟 Record Monitor"
      printf "%s\n" "󰹑 Record Region"
    fi

    printf "%s\n" "$open_folder_label"
  } |
    rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Recorder/R.rasi" \
      -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" \
      -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
  ~/.config/RofiScripts/Launcher/Capture.sh
  exit 0
fi

case "$chosen" in
  "󰖟 Record Monitor") ~/.config/hypr/scripts/screenrec.sh --start monitor ;;
  "󰹑 Record Region") ~/.config/hypr/scripts/screenrec.sh --start region ;;
  "󰓛 Stop Recording") ~/.config/hypr/scripts/screenrec.sh --stop ;;
  "$open_folder_label") ~/.config/hypr/scripts/screenrec.sh --open-dir ;;
  *) exit 1 ;;
esac
