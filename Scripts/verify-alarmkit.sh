#!/usr/bin/env bash
# Verifica que AlarmKit no pueda romper la compilación.
#
# AlarmKit es reciente y su disponibilidad varía entre versiones de Xcode y de iOS.
# Un `import AlarmKit` sin proteger convierte cualquier runner con un SDK distinto en
# un build roto, y el mensaje de error no explica la causa.
#
# Regla: AlarmKit se conserva y se usa, pero siempre de forma progresiva.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
SRC="FERNE"
FAIL=0

fail() { echo "  ✗ $1"; FAIL=1; }
ok()   { echo "  ✓ $1"; }

echo "══ Compatibilidad de AlarmKit ══"
echo

# 1. Todo import debe estar protegido por canImport.
echo "── Importaciones ──"
UNGUARDED=0
while IFS= read -r file; do
  [ -z "$file" ] && continue
  while IFS= read -r line_no; do
    prev=$((line_no - 1))
    context=$(sed -n "$((prev > 3 ? prev - 3 : 1)),${prev}p" "$file")
    if ! printf '%s' "$context" | grep -q '#if canImport(AlarmKit)'; then
      fail "$file:$line_no — 'import AlarmKit' sin #if canImport(AlarmKit)"
      UNGUARDED=1
    fi
  done < <(grep -n '^\s*import AlarmKit' "$file" | cut -d: -f1)
done < <(grep -rl 'import AlarmKit' "$SRC" --include='*.swift' 2>/dev/null)
[ "$UNGUARDED" -eq 0 ] && ok "Todo 'import AlarmKit' está protegido por canImport."

# 2. Todo uso de una API de AlarmKit necesita comprobación de disponibilidad.
echo
echo "── Comprobación de disponibilidad ──"
API_FILES=$(grep -rl 'AlarmManager\|AlarmConfiguration\|AlarmPresentation\|AlarmAttributes' "$SRC" --include='*.swift' 2>/dev/null || true)
if [ -z "$API_FILES" ]; then
  ok "Todavía no se usa ninguna API de AlarmKit (llega en la Fase 4)."
else
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    if grep -q '#available' "$file"; then
      ok "$(basename "$file") comprueba disponibilidad."
    else
      fail "$(basename "$file") usa AlarmKit sin 'if #available'."
    fi
  done <<< "$API_FILES"
fi

# 3. Debe existir la abstracción con fallback.
echo
echo "── Fallback ──"
SHIM="$SRC/Services/Notifications/AlarmCapability.swift"
if [ -f "$SHIM" ]; then
  ok "Existe AlarmCapability."
  grep -q 'case notCompiledIn'  "$SHIM" && ok "Contempla SDK sin AlarmKit."   || fail "Falta el caso 'no compilado'."
  grep -q 'case unsupportedOS'  "$SHIM" && ok "Contempla iOS incompatible."   || fail "Falta el caso 'iOS no compatible'."
  grep -q 'localNotification'   "$SHIM" && ok "Define la vía de fallback."    || fail "No hay ruta de fallback."
  grep -q 'requiresFallback'    "$SHIM" && ok "Expone si hace falta fallback."|| fail "No indica cuándo usar el fallback."
else
  fail "Falta $SHIM. Sin él no hay garantía de fallback."
fi

# 4. El build de simulador no puede depender de firma.
echo
echo "── Build sin firma ──"
if grep -q 'CODE_SIGNING_ALLOWED=NO' .github/workflows/ios-ci.yml; then
  ok "El workflow compila con CODE_SIGNING_ALLOWED=NO."
else
  fail "El workflow no desactiva la firma: el entitlement de AlarmKit podría bloquearlo."
fi

# 5. Los entitlements no aprobados no deben impedir compilar.
echo
echo "── Entitlements ──"
ENT="$SRC/Resources/FERNE.entitlements"
if grep -q 'com.apple.developer.alarmkit' "$ENT"; then
  ok "El entitlement de AlarmKit está declarado (necesario para dispositivo)."
  echo "      Nota: requiere aprobación de Apple. Sin firma no se valida, así que"
  echo "      no bloquea el build de simulador. Si algún día bloquea el archivado,"
  echo "      se separa en un entitlements distinto para Release."
else
  echo "  ⬜ El entitlement no está declarado. Hará falta antes de probar en dispositivo."
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "ALARMKIT: COMPATIBLE Y PROGRESIVO"
else
  echo "ALARMKIT: RIESGO DE ROMPER EL BUILD"
fi
exit $FAIL
