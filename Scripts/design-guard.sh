#!/usr/bin/env bash
# FERNÉ — guardián de diseño y privacidad.
# Análisis estático que corre en cualquier sistema (no necesita Xcode).
# Verifica reglas de MASTER_SPEC §4, §9.3, §10.3 y §13 que de otro modo solo serían
# buenas intenciones escritas en un documento.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/FERNE"
FAIL=0

fail() { echo "  ✗ $1"; FAIL=1; }
pass() { echo "  ✓ $1"; }

echo "== Guardián de diseño =="

# 1. Prohibido negro puro como color de fondo (§4.5).
if grep -rn --include='*.swift' -E 'Color\.black|Color\(white: 0' "$SRC" > /dev/null 2>&1; then
  grep -rn --include='*.swift' -E 'Color\.black|Color\(white: 0' "$SRC"
  fail "Se encontró negro puro. La noche de FERNÉ es ciruela, nunca negra."
else
  pass "Sin negro puro."
fi

# 2. Los hex solo pueden vivir en la capa de tokens.
STRAY_HEX=$(grep -rn --include='*.swift' -E 'Color\(hex: 0x' "$SRC" \
  | grep -v 'DesignSystem/Tokens/FerneColor.swift' \
  | grep -v 'DesignSystem/Theme/FerneTheme.swift' || true)
if [ -n "$STRAY_HEX" ]; then
  echo "$STRAY_HEX"
  fail "Hex fuera de la capa de tokens. Usa FerneColor."
else
  pass "Todos los colores provienen de los tokens."
fi

# 3. La capa Domain no puede depender de UI ni de persistencia (§3.3).
if grep -rn --include='*.swift' -E '^\s*import (SwiftUI|SwiftData|UIKit)' "$SRC/Domain" > /dev/null 2>&1; then
  grep -rn --include='*.swift' -E '^\s*import (SwiftUI|SwiftData|UIKit)' "$SRC/Domain"
  fail "La capa Domain importa UI o persistencia."
else
  pass "Domain permanece puro (solo Foundation)."
fi

# 4. Vocabulario punitivo en cadenas visibles (§9.3).
BAD_WORDS='fracaso|perezos|insuficiente|deficiente|fallaste|incumpliste|verg(ü|u)enza|castigo|penalizaci(ó|o)n'
BAD_HITS=$(grep -rn --include='*.swift' -iE "\"[^\"]*($BAD_WORDS)[^\"]*\"" "$SRC" \
  | grep -v 'ScoreLanguage.swift' || true)
if [ -n "$BAD_HITS" ]; then
  echo "$BAD_HITS"
  fail "Hay vocabulario punitivo en texto visible."
else
  pass "Lenguaje amable en todas las cadenas."
fi

# 5. Sin secretos en el repositorio (§10.3).
SECRET_HITS=$(grep -rn --include='*.swift' --include='*.plist' --include='*.yml' --include='*.json' \
  -E '(sk-[A-Za-z0-9]{16,}|AIza[0-9A-Za-z_-]{20,}|api[_-]?key\s*[:=]\s*"[^"]{12,}")' "$ROOT" \
  --exclude-dir=.build-logic --exclude-dir=build || true)
if [ -n "$SECRET_HITS" ]; then
  echo "$SECRET_HITS"
  fail "Posible secreto en el repositorio."
else
  pass "Sin secretos detectados."
fi

# 6. print() en producción: filtraría datos personales a los logs (§13).
if grep -rn --include='*.swift' -E '(^|[^A-Za-z.])print\(' "$SRC" > /dev/null 2>&1; then
  grep -rn --include='*.swift' -E '(^|[^A-Za-z.])print\(' "$SRC"
  fail "Hay print() en el código. Usa FerneLog y nunca registres datos personales."
else
  pass "Sin print() en el código de la app."
fi

# 7. Los colores atmosféricos solo pueden vivir en escenas y temas (decisión D-022).
#    Si aparecen en una vista de Features, se estarían usando en UI, que está prohibido.
# Seis tokens. `luminousWhite` NO está: es funcional (halos, destellos, realce
# de texto) y puede aparecer en cualquier capa.
ATMOSPHERIC='skyCyan|softIndigo|lavender|dawnPink|dawnPeach|nightPlum'
ATM_HITS=$(grep -rn --include='*.swift' -E "FerneColor\.($ATMOSPHERIC)" "$SRC" \
  | grep -vE 'DesignSystem/(Scenes|Theme)/' \
  | grep -v 'DesignSystem/Tokens/FerneColor.swift' || true)
if [ -n "$ATM_HITS" ]; then
  echo "$ATM_HITS"
  fail "Color atmosférico fuera de una escena. Cian, lavanda e índigo son para cielos, halos y partículas; nunca para botones, formularios ni navegación."
else
  pass "Los colores atmosféricos se quedan en las escenas."
fi

# 8. Toda pantalla debe apoyarse en la escena, nunca en un fondo plano (§14.3).
for view in "$SRC"/Features/*/*View.swift; do
  name="$(basename "$view")"
  if ! grep -qE 'FerneScreen|SkyScene' "$view"; then
    fail "$name no usa FerneScreen/SkyScene: quedaría con fondo plano."
  fi
done
grep -qE 'FerneScreen|SkyScene' "$SRC"/Features/*/*View.swift > /dev/null 2>&1 && pass "Todas las pantallas usan la escena cinematográfica."

echo
if [ "$FAIL" -eq 0 ]; then
  echo "Guardián de diseño: OK"
else
  echo "Guardián de diseño: FALLÓ"
fi
exit $FAIL
