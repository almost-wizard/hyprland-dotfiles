#!/usr/bin/env bash

set -euo pipefail

print_json() {
  local text="$1"
  local cls="$2"
  local tooltip="$3"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$cls" "$tooltip"
}

read_fans() {
  local fans=()
  local f
  for f in /sys/class/hwmon/hwmon*/fan*_input; do
    [[ -r "$f" ]] || continue
    local rpm
    rpm=$(cat "$f" 2>/dev/null || true)
    [[ "$rpm" =~ ^[0-9]+$ ]] || continue
    fans+=("$rpm")
  done

  if (( ${#fans[@]} == 0 )); then
    return 1
  fi

  local sum=0
  local max=0
  local v
  for v in "${fans[@]}"; do
    (( sum += v ))
    (( v > max )) && max=$v
  done

  local avg=$(( sum / ${#fans[@]} ))
  echo "$avg $max ${#fans[@]}"
}

for _ in 1 2 3; do
  if fan_data=$(read_fans); then
    read -r avg max count <<<"$fan_data"
    if (( max == 0 )); then
      print_json "󰈐 idle" "fan-idle" "Fans: ${count} | Avg: ${avg} RPM | Max: ${max} RPM"
    else
      print_json "󰈐 ${avg}RPM" "fan-ok" "Fans: ${count} | Avg: ${avg} RPM | Max: ${max} RPM"
    fi
    exit 0
  fi
  sleep 0.25
done

print_json "󰈐 N/A" "fan-unavailable" "Fan speed sensors not found"
