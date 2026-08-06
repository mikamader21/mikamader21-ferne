#!/usr/bin/env bash
# Extrae los PNG adjuntados por los UI tests desde el bundle .xcresult.
#
# Los UI tests capturan con XCTAttachment(lifetime: .keepAlways). Ese adjunto
# queda dentro del .xcresult, no como archivo suelto: hay que sacarlo.
#
# Uso: bash Scripts/ci/extract-screenshots.sh <ruta.xcresult> <directorio-salida>
set -uo pipefail

RESULT_PATH="${1:-}"
OUTPUT_DIR="${2:-artifacts/screenshots}"

if [ -z "$RESULT_PATH" ] || [ ! -d "$RESULT_PATH" ]; then
  echo "ERROR: falta el .xcresult o no existe: '$RESULT_PATH'"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
RAW_DIR="$(mktemp -d)"

echo "== Extrayendo adjuntos de $RESULT_PATH =="

# Xcode 16+: comando moderno.
if xcrun xcresulttool export attachments \
     --path "$RESULT_PATH" \
     --output-path "$RAW_DIR" > /dev/null 2>&1; then
  echo "  Método: xcresulttool export attachments"
else
  # Xcode 15 y anteriores: recorrido del árbol JSON heredado.
  echo "  Método: recorrido heredado del JSON (--legacy)"
  xcrun xcresulttool get --legacy --format json --path "$RESULT_PATH" > "$RAW_DIR/root.json" 2>/dev/null || true
  python3 - "$RESULT_PATH" "$RAW_DIR" <<'PYTHON'
import json, os, subprocess, sys

result_path, out_dir = sys.argv[1], sys.argv[2]

def get(object_id=None):
    cmd = ["xcrun", "xcresulttool", "get", "--legacy", "--format", "json", "--path", result_path]
    if object_id:
        cmd += ["--id", object_id]
    try:
        return json.loads(subprocess.check_output(cmd, stderr=subprocess.DEVNULL))
    except Exception:
        return {}

def value(node, key):
    return (node.get(key) or {}).get("_value")

def walk(node, seen):
    if isinstance(node, dict):
        if node.get("_type", {}).get("_name") == "ActionTestAttachment":
            ref = (node.get("payloadRef") or {}).get("id", {}).get("_value")
            name = value(node, "filename") or value(node, "name") or f"attachment-{len(seen)}"
            if ref and name.lower().endswith(".png"):
                target = os.path.join(out_dir, name)
                subprocess.run(
                    ["xcrun", "xcresulttool", "export", "--legacy", "--type", "file",
                     "--path", result_path, "--id", ref, "--output-path", target],
                    stderr=subprocess.DEVNULL, check=False)
                seen.append(target)
        for child in node.values():
            walk(child, seen)
    elif isinstance(node, list):
        for child in node:
            walk(child, seen)

root = get()
found = []
walk(root, found)

# Los adjuntos suelen colgar de refs; se sigue un nivel más.
for ref_id in {v for v in json.dumps(root).split('"') if len(v) > 30 and v.isalnum()}:
    walk(get(ref_id), found)

print(f"  Adjuntos PNG extraidos: {len(found)}")
PYTHON
fi

# Normaliza: todo PNG encontrado pasa al directorio de salida con nombre limpio.
COUNT=0
while IFS= read -r png; do
  [ -z "$png" ] && continue
  base="$(basename "$png")"
  cp "$png" "$OUTPUT_DIR/$base" 2>/dev/null && COUNT=$((COUNT + 1))
done < <(find "$RAW_DIR" -name '*.png' 2>/dev/null)

rm -rf "$RAW_DIR"

echo "== Resultado =="
echo "  PNG en $OUTPUT_DIR: $COUNT"
ls -1 "$OUTPUT_DIR" 2>/dev/null | head -50

if [ "$COUNT" -eq 0 ]; then
  # No se hace fallar el pipeline: puede no haber pantallas capturables todavía.
  # Pero queda constancia visible en el log, no un silencio.
  echo "AVISO: no se extrajo ninguna captura. Revisa que ScreenshotTests se haya ejecutado."
fi
exit 0
