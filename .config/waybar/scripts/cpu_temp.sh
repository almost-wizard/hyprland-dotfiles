#!/usr/bin/env bash
set -euo pipefail

resolve_sensor() {
  local label input

  for label in /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_label; do
    [[ -f "$label" ]] || continue
    if [[ "$(cat "$label" 2>/dev/null)" == "Package id 0" ]]; then
      input="${label%_label}_input"
      [[ -f "$input" ]] && { printf '%s\n' "$input"; return 0; }
    fi
  done

  for label in /sys/class/hwmon/hwmon*/temp*_label; do
    [[ -f "$label" ]] || continue
    if [[ "$(cat "$label" 2>/dev/null)" == "Package id 0" ]]; then
      input="${label%_label}_input"
      [[ -f "$input" ]] && { printf '%s\n' "$input"; return 0; }
    fi
  done

  return 1
}

print_json() {
  local text="$1"
  local cls="$2"
  local tooltip="$3"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$cls" "$tooltip"
}

sensor_path="$(resolve_sensor || true)"

if [[ -z "${sensor_path:-}" ]]; then
  while true; do
    print_json " N/A" "temp-unavailable" "CPU package temperature sensor not found"
    sleep 5
  done
fi

while true; do
  raw="$(cat "$sensor_path" 2>/dev/null || true)"
  if [[ -z "$raw" || ! "$raw" =~ ^[0-9]+$ ]]; then
    print_json " N/A" "temp-unavailable" "Failed to read sensor: $sensor_path"
    sleep 2
    continue
  fi

  temp_c=$((raw / 1000))
  cls="temp-normal"
  if (( temp_c >= 80 )); then
    cls="temp-critical"
  elif (( temp_c >= 70 )); then
    cls="temp-warm"
  fi

  print_json " ${temp_c}°C" "$cls" "CPU package temperature: ${temp_c}°C"
  sleep 1
done
