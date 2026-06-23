#!/usr/bin/env bash

set -euo pipefail

LOW_HZ="${LOW_HZ:-60}"
HIGH_HZ="${HIGH_HZ:-90}"

# Function to get the current monitor name
get_monitor() {
    hyprctl monitors | grep "Monitor " | awk '{print $2}' | head -n 1
}

get_monitor_state() {
    local monitor="$1"
    hyprctl monitors | awk -v mon="$monitor" '
        $1=="Monitor" {
            if (in_mon && $2!=mon) { exit }
            in_mon=($2==mon)
            next
        }
        in_mon && $1 ~ /@/ {
            split($1, a, "@")
            res=a[1]
            rate=a[2]
            pos=$3
            next
        }
        in_mon && $1=="scale:" { scale=$2 }
        END { print res, rate, pos, scale }
    '
}

set_refresh() {
    local rate="$1"
    local monitor
    monitor="$(get_monitor)"

    if [ -z "${monitor:-}" ]; then
        monitor="eDP-1"
    fi

    local res current_rate pos scale
    read -r res current_rate pos scale < <(get_monitor_state "$monitor")

    res="${res:-2520x1680}"
    pos="${pos:-0x0}"
    scale="${scale:-1.5}"

    hyprctl keyword monitor "$monitor,${res}@${rate},${pos},${scale}" >/dev/null
}

get_current_rate_int() {
    local monitor="$1"
    local _res rate _pos _scale
    read -r _res rate _pos _scale < <(get_monitor_state "$monitor")
    rate="${rate:-0}"
    rate="${rate%%.*}"
    printf "%s\n" "${rate:-0}"
}

print_status() {
    local monitor rate
    monitor="$(get_monitor)"
    monitor="${monitor:-eDP-1}"
    rate="$(get_current_rate_int "$monitor")"

    if [ "$rate" -ge "$HIGH_HZ" ]; then
        printf "󰄵 %sHz\n" "$rate"
    else
        printf "󰄴 %sHz\n" "$rate"
    fi
}

toggle_refresh() {
    local monitor rate
    monitor="$(get_monitor)"
    monitor="${monitor:-eDP-1}"
    rate="$(get_current_rate_int "$monitor")"

    if [ "$rate" -ge "$HIGH_HZ" ]; then
        set_refresh "$LOW_HZ"
    else
        set_refresh "$HIGH_HZ"
    fi
}

case "${1:-}" in
    --status|"")
        print_status
        ;;
    --toggle)
        toggle_refresh
        ;;
    --set)
        shift
        [ -n "${1:-}" ] || exit 2
        set_refresh "$1"
        ;;
    *)
        echo "Usage: $0 [--status|--toggle|--set <hz>]" >&2
        exit 2
        ;;
esac
