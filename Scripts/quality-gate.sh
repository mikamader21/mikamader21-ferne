#!/usr/bin/env bash
# FERNÉ — quality gate (MASTER_SPEC §14.1).
# Ejecuta todo lo verificable en el sistema actual y reporta con honestidad
# lo que NO pudo comprobarse. Nunca declara éxito por omisión.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
SKIPPED=()

step() { echo; echo "── $1"; }

step "1/11 · Integridad de los documentos maestros"
bash Scripts/verify-spec-integrity.sh || FAIL=1

step "2/11 · Archivos obligatorios"
bash Scripts/ci/check-required-files.sh || FAIL=1

step "3/11 · Finales de línea"
bash Scripts/verify-line-endings.sh || FAIL=1

step "4/11 · Guardián de diseño y privacidad"
bash Scripts/design-guard.sh || FAIL=1
bash Scripts/ci/scan-secrets.sh || FAIL=1

step "5/11 · Fuentes personalizadas"
bash Scripts/verify-fonts.sh || FAIL=1

step "6/11 · Compatibilidad de AlarmKit"
bash Scripts/verify-alarmkit.sh || FAIL=1

step "7/11 · Lógica pura (Domain + Score)"
if command -v swift > /dev/null; then
  bash Scripts/verify-logic.sh > /tmp/ferne-logic.log 2>&1 \
    && grep -E 'Executed [0-9]+ tests' /tmp/ferne-logic.log | tail -1 \
    || { tail -30 /tmp/ferne-logic.log; FAIL=1; }
else
  SKIPPED+=("Pruebas de dominio: no hay toolchain de Swift.")
fi

step "8/11 · SwiftLint"
if command -v swiftlint > /dev/null; then
  swiftlint --strict || FAIL=1
else
  SKIPPED+=("SwiftLint no instalado (brew install swiftlint).")
fi

step "9/11 · Compilación de la app"
if [ "$(uname -s)" = "Darwin" ] && command -v xcodebuild > /dev/null; then
  make build || FAIL=1
else
  SKIPPED+=("Compilación iOS: requiere macOS con Xcode.")
fi

step "10/11 · Pruebas unitarias y de UI"
if [ "$(uname -s)" = "Darwin" ] && command -v xcodebuild > /dev/null; then
  make test || FAIL=1
else
  SKIPPED+=("Pruebas en simulador: requieren macOS con Xcode.")
fi

step "11/11 · Verificaciones que ningún entorno automático puede aprobar"
cat <<'MANUAL'
  NIVEL 2 · revisable en Appetize (cuenta como 🟡, nunca como aprobado):
  - Navegacion entre las cuatro pestanas.
  - Animaciones de escena y check elastico.
  - Reduce Motion con el ajuste REAL del sistema.
  - VoiceOver y Dynamic Type en el simulador remoto.
  - Comparacion contra docs/design-references/ (las 3 referencias oficiales).
  - Pantallas sin imagen propia: coherencia con el sistema derivado.
  - Escena nocturna: luna calida, halo dorado, nubes rosadas, rosado presente.
  - Tipografia: tildes, la E acentuada de FERNE, Dynamic Type.

  NIVEL 3 · exigen el iPhone real de Fer (NO VERIFICADO hasta entonces):
  - Entrega de notificaciones en segundo plano y con pantalla bloqueada.
  - Modo silencio, modos de concentracion y resumen programado.
  - AlarmKit real, volumen y calidad de los seis sonidos.
  - Haptics.
  - Persistencia tras reiniciar el dispositivo.
  - 60 fps medidos con Instruments.

  Detalle: docs/NOTIFICATIONS_TEST_MATRIX.md
MANUAL

echo
echo "════════════════════════════════"
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "OMITIDO en este entorno:"
  for item in "${SKIPPED[@]}"; do echo "  · $item"; done
fi
echo
echo "Recuerda: este gate NO puede aprobar nada del nivel 3."
echo "El pipeline macOS es la fuente de verdad del build: .github/workflows/ios-ci.yml"
echo

if [ "$FAIL" -eq 0 ] && [ ${#SKIPPED[@]} -eq 0 ]; then
  echo "QUALITY GATE: PASA (completo)"
elif [ "$FAIL" -eq 0 ]; then
  echo "QUALITY GATE: PARCIAL — lo ejecutado pasa, pero faltan pasos por entorno."
  exit 2
else
  echo "QUALITY GATE: FALLA"
  exit 1
fi
