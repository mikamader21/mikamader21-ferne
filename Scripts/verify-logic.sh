#!/usr/bin/env bash
# FERNÉ — verificación de la lógica pura (Domain + Score) sin Xcode ni simulador.
#
# Por qué existe: el dominio de FERNÉ es Foundation puro (sin SwiftUI ni SwiftData),
# de modo que puede compilarse y probarse con cualquier toolchain de Swift, también
# en Linux o en CI. Esto NO sustituye a `make test`, que sigue siendo obligatorio
# para la app completa en simulador.
#
# Uso:  bash Scripts/verify-logic.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${FERNE_LOGIC_WORKDIR:-$(mktemp -d -t ferne-logic-XXXXXX)}"

if ! command -v swift > /dev/null; then
  echo "ERROR: no hay toolchain de Swift en el PATH."
  exit 1
fi

# El paquete es efímero: se regenera en cada ejecución copiando las fuentes reales,
# así nunca hay dos copias del código que puedan divergir.
rm -rf "$WORK"
mkdir -p "$WORK/Sources/FerneDomain" "$WORK/Tests/FerneDomainTests"

cp -R "$ROOT/FERNE/Domain/." "$WORK/Sources/FerneDomain/"
cp "$ROOT/FERNETests/TestSupport.swift" "$WORK/Tests/FerneDomainTests/"
cp -R "$ROOT/FERNETests/Domain/." "$WORK/Tests/FerneDomainTests/"

# Rechaza cualquier import de UI o persistencia en el dominio: rompería la
# separación de capas de MASTER_SPEC §3.3 y esta verificación.
if grep -rnE '^\s*import (SwiftUI|SwiftData|UIKit)' "$WORK/Sources/FerneDomain" ; then
  echo "ERROR: la capa Domain no puede importar SwiftUI, SwiftData ni UIKit."
  exit 1
fi

cat > "$WORK/Package.swift" <<'SWIFT'
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FerneDomain",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "FerneDomain"),
        .testTarget(name: "FerneDomainTests", dependencies: ["FerneDomain"])
    ]
)
SWIFT

cd "$WORK"
swift build
swift test
