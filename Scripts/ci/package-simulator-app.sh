#!/usr/bin/env bash
# Empaqueta FERNE.app (build de simulador) en un .zip cargable en Appetize.io.
#
# Appetize espera un ZIP que contenga el bundle .app en la raíz, compilado para
# iOS Simulator. NO es un .ipa y NO lleva firma.
#
# Uso: bash Scripts/ci/package-simulator-app.sh <derivedDataPath> <directorio-salida>
set -euo pipefail

DERIVED="${1:-build/DerivedData}"
OUTPUT_DIR="${2:-artifacts/app}"

APP_PATH=$(find "$DERIVED/Build/Products" -name 'FERNE.app' -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
  echo "ERROR: no se encontró FERNE.app en $DERIVED/Build/Products"
  find "$DERIVED/Build/Products" -maxdepth 3 2>/dev/null || true
  exit 1
fi

echo "== App encontrada =="
echo "  $APP_PATH"

# Comprobación de cordura: un .app sin ejecutable pasaría desapercibido.
if [ ! -f "$APP_PATH/FERNE" ]; then
  echo "ERROR: el bundle no contiene el ejecutable 'FERNE'."
  ls -la "$APP_PATH"
  exit 1
fi

echo "== Arquitecturas =="
lipo -info "$APP_PATH/FERNE" || true

mkdir -p "$OUTPUT_DIR"
ZIP_PATH="$OUTPUT_DIR/FERNE-simulator.zip"
rm -f "$ZIP_PATH"

# -y conserva los symlinks del bundle; sin él, algunos frameworks se corrompen.
( cd "$(dirname "$APP_PATH")" && zip -qry "$OLDPWD/$ZIP_PATH" "$(basename "$APP_PATH")" )

echo "== Paquete listo =="
ls -lh "$ZIP_PATH"
unzip -l "$ZIP_PATH" | head -20

# Metadatos para saber qué build es cada zip al descargarlo semanas después.
cat > "$OUTPUT_DIR/BUILD_INFO.txt" <<INFO
FERNE — build de simulador para Appetize.io

Commit    : ${GITHUB_SHA:-local}
Rama      : ${GITHUB_REF_NAME:-local}
Ejecución : ${GITHUB_RUN_NUMBER:-local}
Fecha     : $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Simulador : ${SIM_NAME:-desconocido} (iOS ${SIM_OS:-desconocido})

Archivo a subir a Appetize: FERNE-simulator.zip
Plataforma en Appetize    : iOS
Tipo                      : Simulator build (sin firma, no es un .ipa)

NO contiene: certificados, perfiles de aprovisionamiento, claves ni datos personales.
INFO

cat "$OUTPUT_DIR/BUILD_INFO.txt"
