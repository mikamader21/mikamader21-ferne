#!/usr/bin/env bash
# Verifica la integridad de los dos documentos maestros.
#
#   docs/FERNE_MASTER_SPEC.md  → original v1.0 CONGELADO. Autoridad final.
#   docs/MASTER_SPEC.md        → copia operativa. Es la ruta que exige §3.4.
#
# Reglas que aplica:
#   1. El original NUNCA debe cambiar. Si cambia, se bloquea y se avisa.
#   2. La copia operativa solo puede diferir del original si hay una decisión
#      registrada en docs/DECISIONS.md y anotada en .spec-integrity.
#   3. Este script NO sobrescribe nada. Solo informa y devuelve un código de salida.
#   4. Ante una divergencia sin decisión: el original tiene prioridad.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FROZEN="docs/FERNE_MASTER_SPEC.md"
WORKING="docs/MASTER_SPEC.md"
REGISTRY=".spec-integrity"

fail() { echo "  ✗ $1"; FAIL=1; }
ok()   { echo "  ✓ $1"; }
FAIL=0

echo "══ Integridad de los documentos maestros ══"
echo

for file in "$FROZEN" "$WORKING"; do
  if [ ! -f "$file" ]; then
    echo "  ✗ FALTA $file"
    echo
    echo "INTEGRIDAD: FALLA — no se puede verificar sin ambos documentos."
    exit 1
  fi
done

FROZEN_SUM=$(sha256sum "$FROZEN" | cut -d' ' -f1)
WORKING_SUM=$(sha256sum "$WORKING" | cut -d' ' -f1)

echo "  original congelado : ${FROZEN_SUM:0:16}…  ($(wc -l < "$FROZEN") líneas)"
echo "  copia operativa    : ${WORKING_SUM:0:16}…  ($(wc -l < "$WORKING") líneas)"
echo

# --- Regla 1: el original no puede haber cambiado -----------------------------
if [ -f "$REGISTRY" ]; then
  EXPECTED_FROZEN=$(grep -E '^frozen_sha256' "$REGISTRY" | cut -d'=' -f2 | tr -d ' ')
  AUTHORIZED=$(grep -E '^authorized_by' "$REGISTRY" | cut -d'=' -f2 | tr -d ' ')
else
  EXPECTED_FROZEN=""
  AUTHORIZED="ninguna"
fi

if [ -z "$EXPECTED_FROZEN" ] || [ "$EXPECTED_FROZEN" = "PENDIENTE" ]; then
  echo "  · Primer registro: se anota el checksum actual del original."
  if [ -f "$REGISTRY" ]; then
    TMP=$(mktemp)
    sed -e "s|^frozen_sha256.*|frozen_sha256 = $FROZEN_SUM|" \
        -e "s|^working_sha256.*|working_sha256 = $WORKING_SUM|" "$REGISTRY" > "$TMP"
    cat "$TMP" > "$REGISTRY"
    rm -f "$TMP"
  fi
  EXPECTED_FROZEN="$FROZEN_SUM"
fi

if [ "$FROZEN_SUM" = "$EXPECTED_FROZEN" ]; then
  ok "El original congelado está intacto."
else
  fail "EL ORIGINAL CONGELADO HA CAMBIADO."
  echo "      esperado : $EXPECTED_FROZEN"
  echo "      actual   : $FROZEN_SUM"
  echo "      Este archivo no debe editarse jamás. Recupéralo antes de continuar."
fi

# --- Regla 2: la copia operativa solo diverge con autorización ----------------
if [ "$FROZEN_SUM" = "$WORKING_SUM" ]; then
  ok "La copia operativa es idéntica al original."
else
  if [ "$AUTHORIZED" = "ninguna" ] || [ -z "$AUTHORIZED" ]; then
    fail "LA COPIA OPERATIVA DIVERGE DEL ORIGINAL SIN DECISIÓN REGISTRADA."
    echo
    echo "      Diferencias (original → copia):"
    diff "$FROZEN" "$WORKING" | head -30 | sed 's/^/        /'
    echo
    echo "      El original tiene prioridad. Para autorizar el cambio:"
    echo "        1. Registra la decisión en docs/DECISIONS.md."
    echo "        2. Anota su identificador en .spec-integrity (authorized_by)."
    echo "        3. Actualiza working_sha256 con el nuevo valor."
  else
    ok "La copia diverge, pero está autorizada por la decisión '$AUTHORIZED'."
    echo "      Recuerda: ante cualquier duda, gana el original."
  fi
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "INTEGRIDAD DE LA ESPECIFICACIÓN: OK"
else
  echo "INTEGRIDAD DE LA ESPECIFICACIÓN: BLOQUEADA"
  echo "No continúes con ninguna fase hasta resolverlo."
fi
exit $FAIL
