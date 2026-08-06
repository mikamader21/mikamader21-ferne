#!/usr/bin/env bash
# Hook PreToolUse · bloquea la escritura de secretos y de archivos sensibles.
# Salida 2 = bloquear la operación. Nunca borra nada: solo impide escribir.
set -uo pipefail

INPUT=$(cat)
read -r FILE CONTENT <<< "$(printf '%s' "$INPUT" | python3 -c '
import json, sys
d = json.load(sys.stdin)
ti = d.get("tool_input", {})
path = ti.get("file_path", "")
content = (ti.get("content") or "") + (ti.get("new_string") or "")
print(path, json.dumps(content))
' 2>/dev/null)"

[ -z "$FILE" ] && exit 0

# 1. Extensiones que nunca deben entrar al repositorio.
case "$FILE" in
  *.p12|*.p8|*.mobileprovision|*.certSigningRequest|*.keystore|*.jks|.env|.env.*)
    echo "BLOQUEADO: '$FILE' es un archivo sensible y no puede versionarse (regla privacy-security)." >&2
    exit 2
    ;;
esac

# 2. Patrones de clave dentro del contenido.
if printf '%s' "$CONTENT" | grep -qE '(sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'; then
  echo "BLOQUEADO: el contenido parece contener una clave real. Usa Keychain, nunca el repositorio." >&2
  exit 2
fi

exit 0
