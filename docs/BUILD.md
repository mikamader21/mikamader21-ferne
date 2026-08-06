# Build, verificación y distribución

FERNÉ se desarrolla desde **Windows**. No hay Mac ni iPhone locales. Hay tres caminos, y cada
uno verifica cosas distintas. Ninguno sustituye a los otros.

```
┌─ 1 · Windows local ──────────┐  ┌─ 2 · GitHub Actions macOS ──┐  ┌─ 3 · Appetize ─────┐
│  Lógica de dominio           │  │  Compilación iOS            │  │  Navegación        │
│  Guards de diseño y capas    │→ │  Tests unitarios y de UI    │→ │  Animaciones       │
│  Integridad del spec         │  │  Cobertura                  │  │  Reduce Motion     │
│  Documentación y galería     │  │  Capturas · artifact .app   │  │  VoiceOver         │
│  Segundos                    │  │  Minutos                    │  │  Interactivo       │
└──────────────────────────────┘  └─────────────────────────────┘  └────────────────────┘
                                              ↓
                                   4 · iPhone real (pendiente)
                          Notificaciones · AlarmKit · sonidos · haptics
```

---

## Camino 1 · Windows local

Lo que puedes ejecutar ahora mismo, sin nada instalado salvo Python y Git Bash (o WSL).

```bash
bash Scripts/verify-logic.sh          # 40 pruebas del dominio (requiere toolchain Swift)
bash Scripts/design-guard.sh          # paleta, capas, lenguaje, secretos, fondos planos
bash Scripts/verify-spec-integrity.sh # los dos documentos maestros no han divergido
bash Scripts/inventory.sh             # inventario oficial de archivos
bash Scripts/ci/scan-secrets.sh       # escaneo de secretos de todo el repositorio
bash Scripts/ci/check-required-files.sh
```

```bat
Scripts\abrir-galeria.bat             REM galería de diseño en el navegador
```

**Instalar Swift en Windows (opcional pero recomendado).** Permite ejecutar
`verify-logic.sh` localmente en lugar de esperar al CI:

1. Descarga el instalador de [swift.org/install/windows](https://www.swift.org/install/windows/).
2. Instala también Visual Studio Build Tools, que el instalador solicita.
3. Comprueba con `swift --version`.

`verify-logic.sh` está escrito para Bash. En Windows úsalo desde **Git Bash** o **WSL**.

> **Lo que este camino NO verifica:** nada de SwiftUI. `Domain/` compila en cualquier sistema
> porque es Foundation puro; las vistas, no. Si rompes una vista, te enterarás en el camino 2.

---

## Camino 2 · GitHub Actions con runner macOS

**Es la fuente de verdad del build.** Si aquí está verde, FERNÉ compila.

### Estado

**Configurado y validado estáticamente; ejecución remota pendiente.** El workflow ha pasado
`actionlint` sin errores y sus scripts tienen la sintaxis comprobada, pero **nunca se ha
ejecutado**. Hasta el primer run en verde, no se puede afirmar que el pipeline funcione.

### Qué hace

Archivo: `.github/workflows/ios-ci.yml`

| Job | Runner | Qué hace |
|---|---|---|
| `preflight` | ubuntu-latest | Archivos obligatorios, secretos, guardián de diseño, 40 pruebas de dominio |
| `ios` | macos-15 | Xcode → XcodeGen → validar proyecto → SwiftFormat → SwiftLint → build → tests unitarios → UI smoke → cobertura → empaquetar `.app` |
| `screenshot-matrix` | ubuntu-latest | Decide en qué iPhones se captura |
| `screenshots` | macos-15 (matriz) | Capturas en compacto, estándar y Pro Max |
| `gallery` | ubuntu-latest | Une las capturas y genera `index.html` |

### Cuándo falla

Por diseño, el pipeline **falla** si:

- No compila.
- Falla cualquier test.
- SwiftLint encuentra un error (`--strict`).
- SwiftFormat detecta formato incorrecto (`--lint`, no escribe).
- Se detecta un secreto o un archivo sensible.
- Falta un archivo obligatorio.
- El proyecto generado es inválido o referencia menos fuentes de las que hay en disco.

Los warnings de compilación **no** rompen el build, pero se cuentan y se listan en el resumen.

### Simulador

No se asume que exista `iPhone 16 Pro`. `Scripts/ci/resolve-simulator.sh` ejecuta
`xcrun simctl list devices available`, elige el mejor iPhone disponible —el solicitado, o un
"Pro", o cualquiera— y **registra cuál usó** en el log y en el resumen de la ejecución.

### Coste

Los minutos de runner macOS se facturan **x10** en repositorios privados. Por eso:

- La matriz de tres tamaños solo corre en `main` o bajo petición manual.
- En ramas de trabajo se captura solo el tamaño estándar.

Para forzar la matriz completa: **Actions → iOS CI → Run workflow →**
`full_screenshot_matrix = true`.

### Comandos equivalentes, si algún día hay un Mac

```bash
brew install xcodegen swiftlint swiftformat
xcodegen generate
xcodebuild build -project FERNE.xcodeproj -scheme FERNE \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO
xcodebuild test -project FERNE.xcodeproj -scheme FERNE \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -derivedDataPath build/DerivedData -enableCodeCoverage YES CODE_SIGNING_ALLOWED=NO
```

El `Makefile` sigue funcionando (`make build`, `make test`, `make gate`) y falla de forma
explícita si no encuentra macOS. Nunca simula un éxito.

---

## Camino 3 · Appetize.io

Preview interactivo en el navegador. Documentación completa en
[`WINDOWS_IOS_PREVIEW.md`](WINDOWS_IOS_PREVIEW.md).

Resumen: descargar el artifact `FERNE-simulator-app`, subir `FERNE-simulator.zip` a Appetize,
abrir la URL. Sirve para navegación, animaciones, layout, Reduce Motion y VoiceOver. **No**
sirve para notificaciones, sonidos, haptics ni rendimiento.

---

## Camino 4 · iPhone real

Pendiente. Ver [`NOTIFICATIONS_TEST_MATRIX.md`](NOTIFICATIONS_TEST_MATRIX.md) para las 12
pruebas que solo un dispositivo puede aprobar.

---

## Conectar el repositorio privado

**Autorizado por Mika el 6 de agosto de 2026.** Todavía no ejecutado: falta autenticar
GitHub CLI en la máquina de Windows.

### Requisito previo: autenticar GitHub CLI

```powershell
winget install --id GitHub.cli
gh auth login
```

En el asistente: **GitHub.com** → **HTTPS** → **Login with a web browser**. Se abre el
navegador, se copia el código de un solo uso que muestra la terminal y listo.

> **Nunca pegues un token de acceso personal en un chat**, ni en este ni en ninguno. El
> flujo por navegador no expone ninguna credencial.

Comprobar:

```powershell
gh auth status
```

### Opción A · Script guiado (recomendado)

```bat
Scripts\conectar-github.bat
```

Hace el preflight, muestra qué se va a versionar, **pide confirmación**, crea el repositorio
privado, configura `origin` y hace push. Se detiene ante cualquier fallo. No usa force push
ni reescribe historial.

### Opción B · Paso a paso

```powershell
cd C:\Users\MIKA\Documents\Claude\Projects\FERNE

# Preflight (Git Bash o WSL)
bash Scripts/ci/scan-secrets.sh
bash Scripts/design-guard.sh
bash Scripts/verify-spec-integrity.sh
bash Scripts/verify-alarmkit.sh

# Repositorio local
git init
git branch -M main
git add -A
git status --short          # REVÍSALO antes de seguir
git commit -m "FERNE: phases 0 and 0.5 foundation"

# Repositorio remoto PRIVADO
gh repo create ferne --private --source=. --remote=origin

# Verificar que es privado ANTES de subir
gh repo view --json isPrivate,url

git push -u origin main
```

### Seguir la primera ejecución

```powershell
gh run list --limit 5     # ver ejecuciones
gh run watch              # seguir en vivo
gh run view --log-failed  # logs de lo que falló
gh run download           # descargar todos los artifacts
```

### Qué esperar de la primera ejecución

Es normal que la primera falle. Los puntos donde suele romperse, y por qué:

| Síntoma | Causa habitual | Dónde mirar |
|---|---|---|
| XcodeGen genera un proyecto vacío | ruta mal en `project.yml` | `verify-generated-project.sh` lo detecta y falla a propósito |
| `No such module 'AlarmKit'` | SDK del runner sin el framework | ya protegido con `#if canImport`; `verify-alarmkit.sh` lo vigila |
| SwiftFormat falla | formato distinto al de `.swiftformat` | artifact `FERNE-build-logs` → `swiftformat.log` |
| SwiftLint falla | regla estricta incumplida | `swiftlint.log` |
| No aparece el simulador | catálogo distinto en el runner | `simulator.log` dice cuál eligió |
| Capturas vacías | el adjunto no sobrevivió al `.xcresult` | `screenshots.log` |
| Fuentes | **no debe fallar**: `verify-fonts.sh` devuelve 0 con archivos pendientes | — |

**No se desactivan pruebas ni reglas para forzar un verde.** Si algo falla, se arregla la
causa.

## TestFlight

Ver el skill `/prepare-testflight`. **Nunca se publica nada sin tu autorización explícita.**
