#!/usr/bin/env bash
# Resuelve un simulador de iPhone realmente disponible en el runner.
#
# Por qué existe: los runners de GitHub cambian de imagen con frecuencia y el
# catálogo de simuladores varía entre versiones de Xcode. Fijar
# "iPhone 16 Pro" a ciegas rompe el pipeline el día que Apple lo retira.
# Este script pregunta al sistema qué hay y elige, con preferencias explícitas.
#
# Salida: escribe SIM_NAME, SIM_UDID, SIM_OS y SIM_DESTINATION en $GITHUB_OUTPUT
# (o en stdout si se ejecuta fuera de Actions).
set -euo pipefail

PREFERRED="${1:-iPhone 16 Pro}"

echo "== Simuladores disponibles =="
xcrun simctl list devices available

RESOLVED=$(xcrun simctl list devices available --json | PREFERRED="$PREFERRED" python3 -c '
import json, os, re, sys

preferred = os.environ["PREFERRED"]
data = json.load(sys.stdin)

def runtime_version(runtime_id: str):
    match = re.search(r"iOS-(\d+)-(\d+)", runtime_id)
    if not match:
        return None
    return (int(match.group(1)), int(match.group(2)))

candidates = []
for runtime, devices in data.get("devices", {}).items():
    version = runtime_version(runtime)
    if version is None:
        continue                      # descarta watchOS, tvOS, visionOS
    for device in devices:
        if not device.get("isAvailable"):
            continue
        name = device.get("name", "")
        if not name.startswith("iPhone"):
            continue                  # el proyecto es solo iPhone (§3.2)
        candidates.append((version, name, device["udid"]))

if not candidates:
    sys.stderr.write("ERROR: el runner no tiene ningun simulador de iPhone disponible.\n")
    sys.exit(1)

# Preferencia 1: el solicitado, en la version de iOS mas alta.
exact = [c for c in candidates if c[1] == preferred]
# Preferencia 2: cualquier iPhone "Pro" (pantalla estandar del proyecto).
pro = [c for c in candidates if "Pro" in c[1] and "Max" not in c[1]]

pool = exact or pro or candidates
pool.sort(key=lambda c: (c[0], c[1]), reverse=True)
version, name, udid = pool[0]

print(f"{name}\t{udid}\t{version[0]}.{version[1]}")
if not exact:
    sys.stderr.write(f"AVISO: '{preferred}' no esta disponible. Se usara '{name}' (iOS {version[0]}.{version[1]}).\n")
')

SIM_NAME=$(printf '%s' "$RESOLVED" | cut -f1)
SIM_UDID=$(printf '%s' "$RESOLVED" | cut -f2)
SIM_OS=$(printf '%s' "$RESOLVED" | cut -f3)
SIM_DESTINATION="platform=iOS Simulator,id=${SIM_UDID}"

echo
echo "== Simulador seleccionado =="
echo "  Nombre : $SIM_NAME"
echo "  UDID   : $SIM_UDID"
echo "  iOS    : $SIM_OS"
echo "  Destino: $SIM_DESTINATION"

# Se usa el UDID y no el nombre: es inequívoco aunque haya duplicados por runtime.
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "sim_name=$SIM_NAME"
    echo "sim_udid=$SIM_UDID"
    echo "sim_os=$SIM_OS"
    echo "sim_destination=$SIM_DESTINATION"
  } >> "$GITHUB_OUTPUT"
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Simulador utilizado"
    echo ""
    echo "| Campo | Valor |"
    echo "|---|---|"
    echo "| Solicitado | \`$PREFERRED\` |"
    echo "| Utilizado | \`$SIM_NAME\` |"
    echo "| iOS | \`$SIM_OS\` |"
    echo "| UDID | \`$SIM_UDID\` |"
  } >> "$GITHUB_STEP_SUMMARY"
fi
