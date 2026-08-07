#!/usr/bin/env bash
# Recopila todo lo que explica un cierre de FERNÉ durante los UI tests.
#
# Se ejecuta SIEMPRE tras el smoke test, pase o falle: cuando falla, esto es lo
# único que permite decir por qué en lugar de suponerlo.
#
# Uso: bash Scripts/ci/collect-diagnostics.sh <directorio-salida>
set -uo pipefail

OUT="${1:-artifacts/diagnostics}"
mkdir -p "$OUT"

echo "══ Recopilando diagnósticos ══"

# ---------------------------------------------------------------------------
# 1. Informes de fallo de la app
# ---------------------------------------------------------------------------
echo
echo "── Crash reports (~/Library/Logs/DiagnosticReports) ──"
CRASHES=0
for dir in "$HOME/Library/Logs/DiagnosticReports" "$HOME/Library/Logs/CrashReporter"; do
  [ -d "$dir" ] || continue
  while IFS= read -r report; do
    [ -z "$report" ] && continue
    cp "$report" "$OUT/" 2>/dev/null && CRASHES=$((CRASHES + 1))
    echo "  · $(basename "$report")"
  done < <(find "$dir" -name 'FERNE*' -newermt '-2 hours' 2>/dev/null)
done
echo "  total: $CRASHES"

# ---------------------------------------------------------------------------
# 2. Logs del simulador para com.ferne.app
# ---------------------------------------------------------------------------
echo
echo "── Logs del simulador (com.ferne.app) ──"
BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -oE '\([0-9A-F-]{36}\)' | tr -d '()' | head -1)
if [ -n "$BOOTED" ]; then
  echo "  simulador arrancado: $BOOTED"
  # Últimos 30 minutos, solo del subsistema de FERNÉ y de los fallos del sistema.
  xcrun simctl spawn "$BOOTED" log show \
    --last 30m \
    --predicate 'subsystem == "com.ferne.app" OR processImagePath CONTAINS "FERNE"' \
    > "$OUT/simulator-ferne.log" 2>/dev/null \
    && echo "  · simulator-ferne.log ($(wc -l < "$OUT/simulator-ferne.log") líneas)"

  # Informes de fallo dentro del contenedor del simulador.
  SIM_CRASHES="$HOME/Library/Logs/DiagnosticReports"
  find "$HOME/Library/Developer/CoreSimulator/Devices/$BOOTED" -name 'FERNE*.ips' 2>/dev/null \
    | while IFS= read -r f; do cp "$f" "$OUT/" 2>/dev/null && echo "  · $(basename "$f")"; done
else
  echo "  (no hay simulador arrancado)"
fi

# ---------------------------------------------------------------------------
# 3. Adjuntos del .xcresult: diagnóstico, jerarquía y capturas del test
# ---------------------------------------------------------------------------
echo
echo "── Adjuntos del .xcresult ──"
for bundle in artifacts/tests/*.xcresult; do
  [ -d "$bundle" ] || continue
  NAME="$(basename "$bundle" .xcresult)"
  DEST="$OUT/attachments-$NAME"
  mkdir -p "$DEST"
  if xcrun xcresulttool export attachments --path "$bundle" --output-path "$DEST" > /dev/null 2>&1; then
    echo "  · $NAME: $(find "$DEST" -type f | wc -l | tr -d ' ') adjuntos"
  else
    echo "  · $NAME: no se pudieron exportar los adjuntos"
  fi
done

# ---------------------------------------------------------------------------
# 4. Resumen legible
# ---------------------------------------------------------------------------
echo
echo "── Resumen ──"
{
  echo "Diagnóstico de FERNÉ"
  echo "Fecha     : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Commit    : ${GITHUB_SHA:-local}"
  echo "Ejecución : ${GITHUB_RUN_NUMBER:-local}"
  echo ""
  echo "Crash reports recogidos : $CRASHES"
  echo "Archivos totales        : $(find "$OUT" -type f | wc -l | tr -d ' ')"
  echo ""
  if [ "$CRASHES" -eq 0 ]; then
    echo "SIN CRASH REPORTS."
    echo "Si un escenario falló sin informe de fallo, la app no terminó de forma"
    echo "abrupta: el motivo está en el diagnóstico del test (página, acción y"
    echo "estado de XCUIApplication), dentro de attachments-*."
  fi
} | tee "$OUT/RESUMEN.txt"

echo
echo "Diagnósticos en: $OUT"
exit 0
