# FERNÉ — comandos de build y verificación
# Requiere macOS + Xcode 16. En otros sistemas fallará de forma explícita (nunca simular éxito).

SCHEME      := FERNE
PROJECT     := FERNE.xcodeproj
DESTINATION := platform=iOS Simulator,name=iPhone 16 Pro,OS=latest
DERIVED     := build/DerivedData

.PHONY: help preflight generate build test lint format gate clean logic-test

help:
	@echo "make preflight   - verifica que el entorno pueda compilar iOS"
	@echo "make generate    - genera FERNE.xcodeproj con XcodeGen"
	@echo "make build       - compila para simulador"
	@echo "make test        - ejecuta pruebas unitarias y de UI"
	@echo "make lint        - SwiftLint"
	@echo "make format      - SwiftFormat (escribe cambios)"
	@echo "make logic-test  - pruebas de lógica pura vía SwiftPM (funciona también en Linux)"
	@echo "make gate        - quality gate completo (generate+lint+build+test)"

preflight:
	@uname -s | grep -q Darwin || (echo "ERROR: se requiere macOS." && exit 1)
	@which xcodebuild > /dev/null || (echo "ERROR: falta Xcode." && exit 1)
	@which xcodegen  > /dev/null || (echo "ERROR: falta XcodeGen. brew install xcodegen" && exit 1)
	@echo "OK: entorno apto."

generate: preflight
	xcodegen generate

build: generate
	set -o pipefail && xcodebuild build \
		-project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED) \
		CODE_SIGNING_ALLOWED=NO | xcbeautify || \
	  xcodebuild build -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -derivedDataPath $(DERIVED) CODE_SIGNING_ALLOWED=NO

test: generate
	set -o pipefail && xcodebuild test \
		-project $(PROJECT) -scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(DERIVED) \
		-enableCodeCoverage YES \
		CODE_SIGNING_ALLOWED=NO

logic-test:
	swift test --package-path FerneCore

lint:
	swiftlint --strict

format:
	swiftformat .

clean:
	rm -rf build FERNE.xcodeproj FerneCore/.build

gate: generate lint build test
	@bash Scripts/quality-gate.sh
