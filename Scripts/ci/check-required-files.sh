#!/usr/bin/env bash
# Falla si falta cualquier archivo obligatorio del proyecto.
#
# Protege contra el fallo silencioso más caro: que el pipeline "pase" porque
# XcodeGen generó un proyecto vacío al no encontrar las fuentes.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
FAIL=0

REQUIRED=(
  "project.yml"
  "Makefile"
  "CLAUDE.md"
  ".swiftlint.yml"
  ".swiftformat"
  "docs/MASTER_SPEC.md"
  "docs/CHECKLIST.md"
  "docs/DECISIONS.md"
  "docs/VISUAL_QA_MATRIX.md"
  "docs/WINDOWS_IOS_PREVIEW.md"
  "docs/NOTIFICATIONS_TEST_MATRIX.md"
  "docs/DESIGN_REFERENCES.md"
  "docs/FERNE_MASTER_SPEC.md"
  ".spec-integrity"
  ".gitattributes"
  "Scripts/verify-line-endings.sh"
  ".github/workflows/ios-ci.yml"
  "Scripts/verify-spec-integrity.sh"
  "Scripts/verify-alarmkit.sh"
  "Scripts/verify-fonts.sh"
  "FERNE/Services/Notifications/AlarmCapability.swift"
  "Scripts/build-gallery.py"
  "FERNE/Core/Utilities/UITestConfiguration.swift"
  "FERNE/PreviewContent/ScreenshotFixtures.swift"
  "FERNEUITests/ScreenshotTests.swift"
  "FERNE/Resources/Info.plist"
  "FERNE/Resources/FERNE.entitlements"
  "FERNE/App/FerneApp.swift"
  "FERNE/Domain/Score/ScoreEngine.swift"
  "FERNE/DesignSystem/Tokens/FerneColor.swift"
  "FERNE/DesignSystem/Scenes/SkyScene.swift"
  "FERNE/PreviewContent/PreviewData.swift"
  "FERNETests/TestSupport.swift"
  "FERNEUITests/SmokeUITests.swift"
)

echo "== Archivos obligatorios =="
for file in "${REQUIRED[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ FALTA $file"
    FAIL=1
  fi
done

# Recuentos mínimos: si alguien borra la mitad del Brain, se nota aquí.
count_at_least() {
  local label="$1" pattern="$2" minimum="$3"
  local found
  found=$(find $pattern -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$found" -lt "$minimum" ]; then
    echo "  ✗ $label: $found (mínimo $minimum)"
    FAIL=1
  else
    echo "  ✓ $label: $found"
  fi
}

echo
echo "== Recuentos mínimos =="
count_at_least "rules"   ".claude/rules"   9
count_at_least "agentes" ".claude/agents"  9
count_at_least "skills"  ".claude/skills"  10
count_at_least "hooks"   ".claude/hooks"   3

# Referencias visuales: el conjunto oficial son TRES imágenes. Están completas.
# Si falta alguna, es un fallo real: sin ellas no hay autoridad visual.
echo
echo "== Referencias visuales (conjunto completo: 3) =="
for ref in 01-splash-approved.png 02-home-approved.png 03-progress-approved.png DESIGN-TOKENS.md; do
  if [ -f "docs/design-references/$ref" ]; then
    echo "  ✓ $ref"
  else
    echo "  ✗ FALTA $ref"
    FAIL=1
  fi
done

echo
if [ "$FAIL" -eq 0 ]; then
  echo "Archivos obligatorios: OK"
else
  echo "Archivos obligatorios: FALTAN PIEZAS"
fi
exit $FAIL
