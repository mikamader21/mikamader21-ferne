#!/usr/bin/env bash
# Inventario oficial del proyecto, con un criterio único y explícito.
#
# Existe porque en el informe de migración aparecieron dos cifras distintas (125 y 126)
# por contar en momentos diferentes. La cifra oficial es la que produce este script.
#
# Criterio:
#   - Se cuenta TODO archivo versionable dentro de la raíz del proyecto.
#   - Se INCLUYEN los archivos ocultos (.gitignore, .gitkeep, .swiftlint.yml...).
#   - Se EXCLUYEN: .git/, build/, DerivedData/, artifacts/, gallery/ y *.xcodeproj/
#     (artefactos generados, no fuente).
#   - Los archivos de docs/design-references/ SÍ cuentan: son entregables del proyecto.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

EXCLUDES=(-path './.git' -o -path './build' -o -path './DerivedData'
          -o -path './artifacts' -o -path './.build-logic' -o -path './gallery' -o -name '*.xcodeproj')

count_files() { find . \( "${EXCLUDES[@]}" \) -prune -o -type f -print | wc -l | tr -d ' '; }
count_dirs()  { find . \( "${EXCLUDES[@]}" \) -prune -o -type d -print | grep -v '^\.$' | wc -l | tr -d ' '; }

TOTAL_FILES=$(count_files)
TOTAL_DIRS=$(count_dirs)

echo "════════════════════════════════════════════"
echo " INVENTARIO OFICIAL DE FERNÉ"
echo " $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "════════════════════════════════════════════"
echo
echo "  Archivos    : $TOTAL_FILES"
echo "  Directorios : $TOTAL_DIRS  (sin contar la raíz)"
echo "  Tamaño      : $(du -sh --exclude=.git --exclude=build . 2>/dev/null | cut -f1)"
echo
echo "── Desglose por área ──"
n() { printf "  %-28s %s\n" "$1" "$2"; }
n "Código Swift (app)"      "$(find ./FERNE -name '*.swift' -type f | wc -l | tr -d ' ')"
n "Pruebas Swift"           "$(find ./FERNETests ./FERNEUITests -name '*.swift' -type f | wc -l | tr -d ' ')"
n "Documentación (docs/*.md)" "$(find ./docs -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"
n "Referencias visuales"    "$(find ./docs/design-references -type f | wc -l | tr -d ' ')"
n "  · PNG de referencia"   "$(find ./docs/design-references -name '*.png' -type f | wc -l | tr -d ' ')"
n "Brain (.claude/)"        "$(find ./.claude -type f | wc -l | tr -d ' ')"
n "Scripts"                 "$(find ./Scripts -type f | wc -l | tr -d ' ')"
n "Workflows (.github/)"    "$(find ./.github -type f | wc -l | tr -d ' ')"
n "Marcadores .gitkeep"     "$(find . -name '.gitkeep' -type f | wc -l | tr -d ' ')"
n "Configuración raíz"      "$(find . -maxdepth 1 -type f | wc -l | tr -d ' ')"
echo
echo "── Archivos ocultos en la raíz ──"
find . -maxdepth 1 -type f -name '.*' -printf '  %f\n' 2>/dev/null | sort
echo
echo "Cifra oficial: $TOTAL_FILES archivos / $TOTAL_DIRS directorios"
