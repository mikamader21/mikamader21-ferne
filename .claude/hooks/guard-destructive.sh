#!/usr/bin/env bash
# Hook PreToolUse · impide comandos destructivos y publicaciones no autorizadas.
# Salida 2 = bloquear. Este hook nunca ejecuta nada por su cuenta.
set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
[ -z "$CMD" ] && exit 0

block() { echo "BLOQUEADO: $1" >&2; exit 2; }

# Borrado recursivo fuera de las carpetas de build.
if printf '%s' "$CMD" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)'; then
  printf '%s' "$CMD" | grep -qE 'rm\s+-[rf]+\s+("?\.?/?(build|DerivedData|\.build|\.build-logic)[^ ]*"?)\s*$' \
    || block "borrado recursivo fuera de build/. Inspecciona el trabajo existente antes de eliminarlo (regla git-workflow)."
fi

# Historial de Git.
printf '%s' "$CMD" | grep -qE 'git\s+(reset\s+--hard|clean\s+-[a-zA-Z]*f|push\s+.*--force|filter-branch|rebase\s+.*-i)' \
  && block "reescribir o descartar historial de Git está prohibido."

# Publicación sin autorización.
printf '%s' "$CMD" | grep -qE 'git\s+(push|tag)|xcrun\s+(altool|notarytool)' \
  && block "no se hacen commits, tags, push ni publicaciones sin autorización explícita de Mika."

# Dependencias no aprobadas.
printf '%s' "$CMD" | grep -qiE '(supabase|firebase|pod\s+install.*(Firebase|Realm)|npm\s+i(nstall)?\s+(react|expo|flutter))' \
  && block "FERNÉ es SwiftUI nativa y offline-first. Sin backend ni tecnología web en el MVP."

exit 0
