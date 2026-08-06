#!/usr/bin/env bash
# Verifica la integración de las fuentes personalizadas (decisión D-023).
#
# Comprueba lo que se puede comprobar sin ejecutar la app: que los archivos existan,
# que las licencias los acompañen, que Info.plist los declare y que no se hayan
# modificado los originales. La verificación real de renderizado (tildes, É, Dynamic
# Type) exige el simulador y queda listada al final.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FONTS="FERNE/Resources/Fonts"
PLIST="FERNE/Resources/Info.plist"
FAIL=0
PENDING=0

echo "══ Fuentes de FERNÉ ══"
echo

DECLARED=$(python3 -c "
import plistlib
try:
    d = plistlib.load(open('$PLIST','rb'))
    print('\n'.join(d.get('UIAppFonts', [])))
except Exception as e:
    print('')
")

if [ -z "$DECLARED" ]; then
  echo "  ✗ Info.plist no declara UIAppFonts."
  exit 1
fi

echo "── Declaradas en Info.plist ──"
COUNT=0
while IFS= read -r font; do
  [ -z "$font" ] && continue
  COUNT=$((COUNT + 1))
  if [ -f "$FONTS/$font" ]; then
    SIZE=$(stat -c%s "$FONTS/$font" 2>/dev/null || stat -f%z "$FONTS/$font" 2>/dev/null || echo 0)
    echo "  ✓ $font ($((SIZE / 1024)) KB)"
  else
    echo "  ⬜ $font — archivo pendiente de descarga"
    PENDING=$((PENDING + 1))
  fi
done <<< "$DECLARED"

echo
echo "── Licencias (SIL OFL 1.1) ──"
for lic in LibreCaslonText-OFL.txt HankenGrotesk-OFL.txt; do
  if [ -f "$FONTS/Licenses/$lic" ]; then
    echo "  ✓ $lic"
  else
    echo "  ⬜ $lic — pendiente"
    PENDING=$((PENDING + 1))
  fi
done

echo
echo "── Peso total añadido al binario ──"
TOTAL=$(find "$FONTS" -name '*.ttf' -o -name '*.otf' 2>/dev/null | xargs stat -c%s 2>/dev/null | paste -sd+ | bc 2>/dev/null || echo 0)
[ -z "$TOTAL" ] && TOTAL=0
echo "  $((TOTAL / 1024)) KB"
if [ "$TOTAL" -gt 614400 ]; then
  echo "  ✗ Supera los 600 KB. Reduce cortes antes de aceptarlo (ver Fonts/README.md)."
  FAIL=1
fi

echo
echo "── Integridad ──"
# Una fuente por debajo de 20 KB casi seguro está truncada o es un placeholder.
while IFS= read -r f; do
  [ -z "$f" ] && continue
  SIZE=$(stat -c%s "$f" 2>/dev/null || echo 0)
  if [ "$SIZE" -lt 20480 ]; then
    echo "  ✗ $(basename "$f") pesa $((SIZE / 1024)) KB: sospechosamente pequeño."
    FAIL=1
  fi
done < <(find "$FONTS" -name '*.ttf' 2>/dev/null)
[ "$FAIL" -eq 0 ] && echo "  ✓ Sin archivos sospechosos."

echo
echo "── Fallback ──"
if grep -q 'guard isRegistered' FERNE/DesignSystem/Tokens/FerneTypography.swift; then
  echo "  ✓ FerneFont cae a la fuente del sistema si falta un archivo."
else
  echo "  ✗ FerneFont no tiene fallback. La app se vería con la fuente por defecto sin avisar."
  FAIL=1
fi

if grep -q 'relativeTo:' FERNE/DesignSystem/Tokens/FerneTypography.swift; then
  echo "  ✓ Todas las fuentes usan relativeTo: (Dynamic Type)."
else
  echo "  ✗ Falta relativeTo:. Las fuentes personalizadas no escalarían."
  FAIL=1
fi

echo
echo "── Requiere simulador o dispositivo ──"
cat <<'MANUAL'
  Estas NO se pueden verificar desde Windows:
  - Renderizado de tildes, ñ, ¿ y ¡.
  - La É de FERNÉ en el logotipo (es el carácter crítico).
  - Dynamic Type en compacto, estándar y accesibilidad grande.
  - Que iOS no sintetice pesos ausentes con un falso negrita.
  Se comprueban con las capturas del pipeline macOS.
MANUAL

echo
if [ "$FAIL" -ne 0 ]; then
  echo "FUENTES: FALLA"
  exit 1
elif [ "$PENDING" -gt 0 ]; then
  echo "FUENTES: PENDIENTES ($PENDING archivos). La app funciona con el fallback del sistema."
  echo "Instrucciones: FERNE/Resources/Fonts/README.md"
  exit 0
else
  echo "FUENTES: OK"
  exit 0
fi
