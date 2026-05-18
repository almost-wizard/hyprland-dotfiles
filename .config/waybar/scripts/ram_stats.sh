#!/usr/bin/env bash
set -euo pipefail

to_gib_1() {
  awk -v kb="$1" 'BEGIN { printf "%.1f", kb / 1048576 }'
}

mem_total_kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)"
mem_avail_kb="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"
swap_total_kb="$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)"
swap_free_kb="$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)"

mem_used_kb=$((mem_total_kb - mem_avail_kb))
mem_percent="$(awk -v u="$mem_used_kb" -v t="$mem_total_kb" 'BEGIN { printf "%.0f", (u / t) * 100 }')"

swap_used_kb=$((swap_total_kb - swap_free_kb))
if [ "$swap_total_kb" -gt 0 ]; then
  swap_percent="$(awk -v u="$swap_used_kb" -v t="$swap_total_kb" 'BEGIN { printf "%.0f", (u / t) * 100 }')"
else
  swap_percent="0"
fi

ram_used_gib="$(to_gib_1 "$mem_used_kb")"
ram_total_gib="$(to_gib_1 "$mem_total_kb")"
swap_used_gib="$(to_gib_1 "$swap_used_kb")"
swap_total_gib="$(to_gib_1 "$swap_total_kb")"
read -r root_used root_total root_pct < <(df -hP / | awk 'NR==2 {print $3, $2, $5}')

text=" ${ram_used_gib}GiB"
tooltip="RAM used: ${ram_used_gib}GiB / ${ram_total_gib}GiB (${mem_percent}%)"
tooltip+="\nSWAP used: ${swap_used_gib}GiB / ${swap_total_gib}GiB (${swap_percent}%)"
tooltip+="\nDISK \"/\" used: ${root_used} / ${root_total} (${root_pct})"

tooltip="${tooltip//\"/\\\"}"
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
