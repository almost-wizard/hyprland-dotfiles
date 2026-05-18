#!/usr/bin/env bash
set -euo pipefail

src="${HOME}/.cache/neo/matugen.json"
out_dir="${HOME}/.config/neo"
out_file="${out_dir}/colors-matugen.neo"

mkdir -p "${out_dir}"

to_1000() {
  local hex="$1"
  printf '%d' $(( (16#${hex} * 1000 + 127) / 255 ))
}

write_line() {
  local code="$1"
  local hex="${2#\#}"
  local r="${hex:0:2}"
  local g="${hex:2:2}"
  local b="${hex:4:2}"
  printf '%s,%s,%s,%s\n' "${code}" "$(to_1000 "${r}")" "$(to_1000 "${g}")" "$(to_1000 "${b}")"
}

mapfile -t fg_hexes < <(jq -r '.colors[]' "${src}")

{
  echo "neo_color_version 1"
  echo "-1"
  write_line 34 "${fg_hexes[0]}"
  write_line 40 "${fg_hexes[1]}"
  write_line 46 "${fg_hexes[2]}"
  write_line 82 "${fg_hexes[3]}"
  write_line 120 "${fg_hexes[4]}"
  write_line 231 "${fg_hexes[5]}"
} > "${out_file}"
