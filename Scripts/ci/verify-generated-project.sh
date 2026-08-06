#!/usr/bin/env bash
# Comprueba que el .xcodeproj generado por XcodeGen es válido y completo.
#
# XcodeGen puede terminar con éxito y producir un proyecto sin fuentes si una
# ruta de project.yml está mal. Ese proyecto compilaría "correctamente" un
# binario vacío y el pipeline quedaría verde mintiendo.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
PROJECT="FERNE.xcodeproj"
FAIL=0

if [ ! -d "$PROJECT" ]; then
  echo "✗ No existe $PROJECT. XcodeGen no generó nada."
  exit 1
fi

if [ ! -f "$PROJECT/project.pbxproj" ]; then
  echo "✗ $PROJECT no contiene project.pbxproj."
  exit 1
fi

echo "== Targets y esquemas =="
if ! xcodebuild -list -project "$PROJECT" > /tmp/ferne-xcodelist.txt 2>&1; then
  echo "✗ xcodebuild -list falló: el proyecto está corrupto."
  cat /tmp/ferne-xcodelist.txt
  exit 1
fi
cat /tmp/ferne-xcodelist.txt

for target in FERNE FERNETests FERNEUITests; do
  if grep -q "^ *$target$" /tmp/ferne-xcodelist.txt; then
    echo "  ✓ target $target"
  else
    echo "  ✗ falta el target $target"
    FAIL=1
  fi
done

if grep -q "^ *FERNE$" /tmp/ferne-xcodelist.txt; then
  echo "  ✓ esquema FERNE"
else
  echo "  ✗ falta el esquema FERNE"
  FAIL=1
fi

# El proyecto debe referenciar un número creíble de fuentes Swift.
SOURCES_IN_DISK=$(find FERNE -name '*.swift' | wc -l | tr -d ' ')
SOURCES_IN_PROJECT=$(grep -c '\.swift' "$PROJECT/project.pbxproj" || true)
echo
echo "== Fuentes =="
echo "  En disco:   $SOURCES_IN_DISK"
echo "  Referencias en el proyecto: $SOURCES_IN_PROJECT"
if [ "$SOURCES_IN_PROJECT" -lt "$SOURCES_IN_DISK" ]; then
  echo "  ✗ El proyecto referencia menos fuentes que las que hay en disco."
  FAIL=1
else
  echo "  ✓ Todas las fuentes están referenciadas."
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "Proyecto generado: VÁLIDO"
else
  echo "Proyecto generado: INVÁLIDO"
fi
exit $FAIL
