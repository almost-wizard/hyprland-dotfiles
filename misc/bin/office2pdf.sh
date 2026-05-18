#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  office2pdf [FILES_OR_DIRS...]

Examples:
  office2pdf *.docx *.pptx
  office2pdf *
  office2pdf ./documents ./slides

If no arguments are passed, supported files in the current directory are converted.
USAGE
}

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v soffice >/dev/null 2>&1; then
  echo "Error: soffice not found. Install LibreOffice first." >&2
  exit 1
fi

supported_re='\.(doc|docx|odt|rtf|ppt|pptx|odp|xls|xlsx|ods)$'

declare -a inputs=()

collect_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  shopt -s nocasematch
  if [[ "$f" =~ $supported_re ]]; then
    inputs+=("$f")
  fi
  shopt -u nocasematch
}

if [[ "$#" -eq 0 ]]; then
  while IFS= read -r -d '' f; do
    collect_file "$f"
  done < <(find . -maxdepth 1 -type f -print0)
else
  for arg in "$@"; do
    if [[ -d "$arg" ]]; then
      while IFS= read -r -d '' f; do
        collect_file "$f"
      done < <(find "$arg" -type f -print0)
    else
      collect_file "$arg"
    fi
  done
fi

if [[ "${#inputs[@]}" -eq 0 ]]; then
  echo "No supported files found." >&2
  exit 1
fi

echo "Converting ${#inputs[@]} file(s) to PDF..."

ok=0
failed=0
for f in "${inputs[@]}"; do
  outdir="$(dirname "$f")"
  base="$(basename "$f")"
  pdf_name="${base%.*}.pdf"
  pdf_path="$outdir/$pdf_name"

  rm -f -- "$pdf_path"
  log_file="$(mktemp)"
  if soffice --headless --convert-to pdf --outdir "$outdir" "$f" >"$log_file" 2>&1 \
    && [[ -f "$pdf_path" ]]; then
      printf 'OK: %s -> %s\n' "$f" "$pdf_path"
      ((ok += 1))
    else
      printf 'FAIL: %s (expected: %s)\n' "$f" "$pdf_path" >&2
      sed 's/^/  soffice: /' "$log_file" >&2 || true
      ((failed += 1))
  fi
  rm -f -- "$log_file"
done

echo "Done. Success: $ok, Failed: $failed"
[[ "$failed" -eq 0 ]]
