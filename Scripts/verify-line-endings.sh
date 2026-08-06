#!/usr/bin/env bash
# Verifica la política de finales de línea (decisión D-030).
#
# Por qué importa: si un .sh llega a un runner Linux con CRLF, el shell intenta
# ejecutar "/usr/bin/env bash\r" y falla con un mensaje que no menciona el motivo
# real. Y un archivo de texto con CRLF produce un sha256 distinto, lo que haría
# saltar verify-spec-integrity.sh por una divergencia inexistente.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0

echo "══ Finales de línea ══"
echo

if [ ! -f .gitattributes ]; then
  echo "  ✗ Falta .gitattributes. Sin él, Windows corrompería los scripts al hacer checkout."
  exit 1
fi
echo "  ✓ .gitattributes presente."

# --- Deben ser LF ---
echo
echo "── Deben ser LF ──"
LF_BAD=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  if grep -qU $'\r' "$f" 2>/dev/null; then
    echo "  ✗ $f contiene CRLF"
    LF_BAD=$((LF_BAD + 1)); FAIL=1
  fi
done < <(find . -type f \( -name '*.sh' -o -name '*.yml' -o -name '*.yaml' -o -name '*.swift' \
         -o -name '*.md' -o -name '*.py' -o -name '*.plist' -o -name '*.entitlements' \
         -o -name 'Makefile' -o -name '.spec-integrity' -o -name '.gitignore' \) \
         -not -path './gallery/*' -not -path './.git/*' -not -path './build/*')
[ "$LF_BAD" -eq 0 ] && echo "  ✓ Ningún archivo de texto contiene CRLF."

# --- El shebang no puede llevar \r ---
echo
echo "── Shebang de los scripts ──"
SHEBANG_BAD=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  if head -1 "$f" | grep -qU $'\r'; then
    echo "  ✗ $f: el shebang lleva \\r. Fallaría con 'bad interpreter'."
    SHEBANG_BAD=$((SHEBANG_BAD + 1)); FAIL=1
  fi
done < <(find . -name '*.sh' -not -path './gallery/*')
[ "$SHEBANG_BAD" -eq 0 ] && echo "  ✓ Todos los shebang están limpios ($(find . -name '*.sh' -not -path './gallery/*' | wc -l | tr -d ' ') scripts)."

# --- Deben ser CRLF ---
echo
echo "── Deben ser CRLF (ejecutables de Windows) ──"
CRLF_BAD=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  if ! grep -qU $'\r' "$f" 2>/dev/null; then
    echo "  ⬜ $f está en LF. Git lo convertirá al hacer checkout, pero conviene guardarlo ya en CRLF."
    CRLF_BAD=$((CRLF_BAD + 1))
  fi
done < <(find . -type f \( -name '*.bat' -o -name '*.cmd' -o -name '*.ps1' \) -not -path './gallery/*')
[ "$CRLF_BAD" -eq 0 ] && echo "  ✓ Los ejecutables de Windows están en CRLF."

# --- Los binarios no pueden estar declarados como texto ---
echo
echo "── Binarios protegidos ──"
for ext in png jpg ttf otf caf wav zip; do
  if grep -qE "^\*\.$ext[[:space:]]+binary" .gitattributes; then
    echo "  ✓ *.$ext declarado binary"
  else
    echo "  ✗ *.$ext NO está protegido. Git podría corromperlo."
    FAIL=1
  fi
done

echo
if [ "$FAIL" -eq 0 ]; then
  echo "FINALES DE LÍNEA: OK"
else
  echo "FINALES DE LÍNEA: FALLA"
fi
exit $FAIL
