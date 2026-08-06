#!/usr/bin/env bash
# Hook PostToolUse · formatea y revisa SOLO el archivo Swift recién editado.
# Seguro por diseño: no borra, no reescribe ramas, no toca nada fuera del archivo.
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0
case "$FILE" in *.swift) ;; *) exit 0 ;; esac

if command -v swiftformat > /dev/null; then
  swiftformat "$FILE" --quiet 2>/dev/null || true
fi

if command -v swiftlint > /dev/null; then
  OUT=$(swiftlint lint --quiet --path "$FILE" 2>/dev/null || true)
  if [ -n "$OUT" ]; then
    echo "SwiftLint en $(basename "$FILE"):"
    echo "$OUT"
  fi
fi
exit 0
