#!/usr/bin/env bash
# Escaneo de secretos para CI. Más estricto que design-guard.sh porque revisa
# TODO el repositorio, no solo el código de la app, e incluye el historial de
# archivos añadidos en el push.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
FAIL=0

echo "== Archivos prohibidos =="
FORBIDDEN=$(find . -type f \
  \( -name '*.p12' -o -name '*.p8' -o -name '*.mobileprovision' \
     -o -name '*.certSigningRequest' -o -name '.env' -o -name '.env.*' \
     -o -name 'Secrets.xcconfig' \) \
  -not -path './.git/*' 2>/dev/null || true)
if [ -n "$FORBIDDEN" ]; then
  echo "$FORBIDDEN"
  echo "  ✗ Hay archivos sensibles versionados."
  FAIL=1
else
  echo "  ✓ Ninguno."
fi

echo
echo "== Patrones de clave =="
PATTERNS='sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{30,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}'
HITS=$(grep -rInE "$PATTERNS" . \
  --exclude-dir=.git --exclude-dir=build --exclude-dir=DerivedData \
  --exclude-dir=artifacts --exclude-dir=node_modules \
  --exclude='scan-secrets.sh' --exclude='design-guard.sh' \
  --exclude='guard-secrets.sh' 2>/dev/null || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  echo "  ✗ Posible secreto en el repositorio."
  FAIL=1
else
  echo "  ✓ Ninguno."
fi

echo
echo "== Team ID de Apple filtrado =="
# project.yml debe dejar DEVELOPMENT_TEAM vacío.
TEAM=$(grep -rn 'DEVELOPMENT_TEAM' project.yml 2>/dev/null | grep -vE 'DEVELOPMENT_TEAM: *""' || true)
if [ -n "$TEAM" ]; then
  echo "$TEAM"
  echo "  ✗ Hay un Team ID en project.yml. Debe introducirse localmente."
  FAIL=1
else
  echo "  ✓ project.yml no contiene Team ID."
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "Escaneo de secretos: LIMPIO"
else
  echo "Escaneo de secretos: FALLA"
fi
exit $FAIL
