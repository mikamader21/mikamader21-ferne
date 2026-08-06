# Checklist del proyecto

Última actualización: **6 de agosto de 2026**

**Fase 0.5:** configurada, documentada y validada estáticamente. **Pendiente de primera
ejecución remota en GitHub Actions.**

**Ubicación oficial:** `C:\Users\MIKA\Documents\Claude\Projects\FERNE`

## Migración a ubicación permanente ✅

- [x] Carpeta permanente creada
- [x] 125 archivos copiados
- [x] Verificación por checksum MD5: **125/125 idénticos byte a byte**
- [x] `CLAUDE.md` en la raíz
- [x] `docs/MASTER_SPEC.md` (copia de trabajo) y `docs/FERNE_MASTER_SPEC.md` (original congelado)
- [x] `docs/design-references/` en la ruta correcta, sin duplicación `FERNE\FERNE`
- [x] Documentación actualizada: ninguna referencia a la ruta temporal
- [x] Carpeta temporal conservada como respaldo congelado (no borrada)

## Fase 0 — Preparación

### Repositorio y proyecto
- [x] Estructura modular según §3.4
- [x] `project.yml` (XcodeGen) con targets app + unit tests + UI tests
- [x] `Info.plist` y `FERNE.entitlements` (CloudKit, Push, AlarmKit)
- [x] `Makefile` con generate/build/test/lint/gate
- [x] `.gitignore` con exclusión de secretos y certificados
- [x] `.swiftlint.yml` con reglas propias (sin hex sueltos, sin negro puro, sin `print`)
- [x] `.swiftformat`
- [ ] **`FERNE.xcodeproj` generado** — requiere macOS

### Brain de Claude Code
- [x] `CLAUDE.md`
- [x] `.claude/settings.json` con permisos y hooks
- [x] 9 rules
- [x] 9 agentes
- [x] 10 skills
- [x] 3 hooks, probados uno a uno

### Documentación (16 archivos)
- [x] `MASTER_SPEC.md` (copia íntegra, fuente de verdad)
- [x] `PRODUCT.md` · `SCREEN_CATALOG.md` · `DESIGN_SYSTEM.md` · `ARCHITECTURE.md`
- [x] `DATA_MODELS.md` · `NOTIFICATIONS.md` · `MOTION_SYSTEM.md` · `SCORE_ENGINE.md`
- [x] `PRIVACY.md` · `QA_PLAN.md` · `ACCEPTANCE_TESTS.md`
- [x] `BUILD.md` · `PHASE_PLAN.md` · `CHECKLIST.md` · `DECISIONS.md`

### Sistema de diseño
- [x] 12 tokens de color + rojo reservado + roles semánticos
- [x] Tipografía con Dynamic Type
- [x] Espaciado, radios y tamaños táctiles
- [x] Tokens de movimiento con rangos verificados por prueba
- [x] Temas mañana / tarde / noche
- [x] `SkyScene`: cielo, sol/luna, halo, nubes, estrellas, partículas
- [x] 8 componentes base
- [x] Reduce Motion y Reduce Transparency contemplados

### Dominio
- [x] `ActivitySnapshot`, `ActivityCategory` (12), `ActivityStatus` (6), `Priority`, `RecurrenceRule`
- [x] `DayPhase` + provider inyectable
- [x] `ScoreEngine`, `DailyScore`, `WeeklyScore`
- [x] `ScoreLanguage` + `Recommendation`
- [x] Capa pura verificada por script

### Navegación y datos de preview
- [x] `FerneApp` + `AppRootView` + `MainTabView` (4 pestañas)
- [x] Splash con variantes día/noche
- [x] Esqueletos de Inicio, Progreso, Destellos, Perfil
- [x] `PreviewData` determinista

### Pruebas
- [x] 40 pruebas de dominio — **40/40 pasan** (Swift 6.0.3)
- [x] Los 8 casos obligatorios de §9.4 cubiertos
- [x] `ThemeTests` (10 pruebas, requieren Xcode)
- [x] `SmokeUITests` (2 pruebas, requieren simulador)
- [ ] **Ejecutar `make test`** — requiere macOS

### Quality gate
- [x] `design-guard.sh` — 7/7 comprobaciones en verde
- [x] `verify-logic.sh` — 40/40
- [x] `quality-gate.sh` escrito, reporta honestamente lo omitido
- [ ] **Compilación iOS** — NO VERIFICADO
- [ ] **UI tests** — NO VERIFICADO
- [ ] **Notificaciones en dispositivo** — no aplica todavía (Fase 4)
- [ ] **Comparación visual contra referencias** — bloqueado, faltan las referencias

## Fase 0.5 — Desarrollo iOS desde Windows

### Pipeline macOS
- [x] `.github/workflows/ios-ci.yml` con 5 jobs
- [x] Runner oficial `macos-15`
- [x] Selección explícita de Xcode
- [x] XcodeGen instalado de forma controlada
- [x] Generación y **validación** del proyecto (falla si referencia menos fuentes de las que hay)
- [x] Resolución dinámica de simulador, con registro del elegido
- [x] Compilación sin firma para iOS Simulator
- [x] Tests unitarios · UI smoke · cobertura
- [x] SwiftFormat en modo verificación · SwiftLint estricto
- [x] Falla ante secreto, archivo obligatorio ausente o proyecto inválido
- [x] Validado con `actionlint`: sin errores
- [ ] **Ejecutado en GitHub** — repositorio no creado

### Artifacts
- [x] `FERNE-simulator-app` (con `BUILD_INFO.txt`)
- [x] `FERNE-test-results` · `FERNE-code-coverage` · `FERNE-build-logs`
- [x] `FERNE-screenshots` unificado desde la matriz de dispositivos
- [x] ZIP compatible con Appetize (bundle `.app` en la raíz, sin firma)
- [ ] **Descargados y verificados** — pendiente de la primera ejecución

### Capturas y QA visual
- [x] `ScreenshotTests` con 6 escenarios
- [x] `UITestConfiguration` + `ScreenshotFixtures` deterministas
- [x] Matriz de 3 tamaños de iPhone, con control de coste
- [x] Mañana · tarde · noche · vacío · completo · Dynamic Type · Reduce Motion · splash · 4 pestañas
- [x] `docs/VISUAL_QA_MATRIX.md`
- [x] Identificadores de accesibilidad en las 5 vistas
- [ ] **Capturas reales generadas** — pendiente

### Galería para Windows
- [x] `Scripts/build-gallery.py`, probado con y sin capturas
- [x] `Scripts/abrir-galeria.bat` y `.ps1`
- [x] Muestra referencias + capturas + estado por pantalla
- [x] Aviso permanente de que no es la app
- [x] No reconstruye FERNÉ en HTML/React/JS

### Documentación
- [x] `docs/WINDOWS_IOS_PREVIEW.md`
- [x] `docs/NOTIFICATIONS_TEST_MATRIX.md` (13 + 7 + 12 pruebas clasificadas)
- [x] `docs/DESIGN_REFERENCES.md`
- [x] `docs/BUILD.md` con los cuatro caminos
- [x] `docs/PHASE_PLAN.md` con Fase 0.5 y sin requisito de Mac local
- [x] `docs/DESIGN_SYSTEM.md` con la autoridad visual

### Integridad y control
- [x] `Scripts/verify-spec-integrity.sh` — probado con divergencia real
- [x] `.spec-integrity` con los sha256 aprobados
- [x] `Scripts/inventory.sh` — cifra oficial única
- [x] `quality-gate.sh` ampliado a 8 pasos

### Referencias visuales — conjunto COMPLETO
- [x] `01-splash-approved.png` recibida y verificada (sha256 registrado)
- [x] `02-home-approved.png` recibida y verificada
- [x] `03-progress-approved.png` recibida y verificada
- [x] `DESIGN-TOKENS.md` analizado
- [x] Dirección visual general **aprobada**: las tres imágenes gobiernan las 40 pantallas
- [x] Dirección nocturna **derivada y documentada** (D-024)
- [x] Colores del Splash **aprobados tal cual** (D-022)
- [x] Paleta reorganizada en funcionales + atmosféricos
- [x] Guardián que aísla los atmosféricos de la UI, probado con violación real
- [x] Tipografía **aprobada** (D-023): Libre Caslon Text + Hanken Grotesk
- [x] `FerneFont` con fallback al sistema y Dynamic Type
- [x] `Scripts/verify-fonts.sh`
- [x] `docs/VISUAL_BACKLOG.md` con 25 diferencias P0–P3
- [ ] Archivos `.ttf` y sus licencias OFL — pendientes de descarga
- [ ] **Comparación real contra las referencias** — solo hasta ejecutar el pipeline

### Integración con el Brain
- [x] 4 agentes actualizados: visual-guardian, qa-engineer, release-engineer, notification-engineer
- [x] 4 skills actualizados: verify-design, run-quality-gate, test-notifications, prepare-testflight
- [x] Skill nuevo: `preview-windows` (11 en total)
- [x] `CLAUDE.md` con entorno, referencias y 13 reglas innegociables

## Primera ejecución del pipeline

**Autorizada por Mika el 6 de agosto de 2026. Aún no realizada.**

### Preflight — completado
- [x] Escaneo de secretos: LIMPIO
- [x] `.gitignore` reforzado: `*.p8`, `*.pem`, `*.key`, `artifacts/`, `*.xcresult/`, `outputs/`
- [x] Simulacro de commit: **155 archivos, 3,7 MB, nada prohibido**
- [x] 40 pruebas de dominio en verde
- [x] Design Guard 8/8
- [x] Integridad del documento maestro: OK
- [x] Fuentes: PENDIENTES, no error (no bloquea)
- [x] AlarmKit: compatible y progresivo
- [x] `actionlint`: sin errores

### AlarmKit — verificado antes de existir
- [x] `AlarmCapability.swift` con `#if canImport(AlarmKit)`
- [x] Contempla SDK sin el framework y iOS incompatible
- [x] Fallback completo a `UserNotifications`
- [x] Solo `Priority.esencial` opta a alarma prominente
- [x] Build de simulador sin firma
- [x] `Scripts/verify-alarmkit.sh` en el quality gate y en el workflow

### GitHub — DETENIDO
- [ ] **`gh auth status`: GitHub CLI no autenticado**
- [ ] Repositorio privado `ferne` creado
- [ ] Commit `FERNE: phases 0 and 0.5 foundation`
- [ ] Push de `main`
- [ ] Confirmación de que el remoto es privado
- [ ] Primera ejecución del workflow
- [ ] Build verde · tests verdes · `FERNE.app` · capturas · cobertura
- [ ] Artifacts descargados y verificados
- [ ] Build abierto en Appetize

**Motivo de la parada:** GitHub CLI no está instalado ni autenticado en la máquina de
Windows, y el entorno de trabajo de Claude está aislado de esas credenciales. Instrucciones
en `BUILD.md`; script guiado en `Scripts/conectar-github.bat`.

## Bloqueos abiertos

| # | Bloqueo | Impacto | Qué se necesita |
|---|---|---|---|
| 1 | GitHub CLI sin autenticar | El pipeline nunca se ha ejecutado | `gh auth login` en Windows. Autorización ya concedida. |
| 2 | Archivos `.ttf` de las fuentes | La app usa el fallback del sistema; la tipografía no es la aprobada | Descargarlos de Google Fonts. Instrucciones en `FERNE/Resources/Fonts/README.md` |
| 3 | No existen los 6 archivos de audio | Los sonidos no pueden sonar | Audio original o con licencia. **No bloquea las Fases 1, 2 ni 3.** Debe resolverse antes de aprobar la Fase 4 |
| 4 | Sin iPhone físico | 12 pruebas de nivel 3 en NO VERIFICADO | Un iPhone con iOS 18+ y firma |
| 5 | Decisiones de firma sin confirmar | Bloquea Fase 8 | Team ID, bundle ID definitivo, dispositivo |

**Resueltos en la Fase 0.5:**

- "Sin macOS ni Xcode" → la compilación ya tiene dónde ocurrir.
- "Faltan las referencias visuales" → recibidas, verificadas y son el conjunto completo.
- "Comparación visual bloqueada" → no lo está; solo espera a las capturas del pipeline.
- "No existe dirección nocturna" → derivada y documentada (D-024).
- "Ninguna pantalla puede aprobarse" → todas son evaluables contra el sistema derivado.

## Fases siguientes

- [🔵] Fase 0.5 — Desarrollo iOS desde Windows *(configurada y validada; pendiente de primera ejecución remota)*
- [ ] Fase 1 — Núcleo funcional
- [ ] Fase 2 — Inicio y agenda
- [ ] Fase 3 — Categorías
- [ ] Fase 4 — Notificaciones
- [ ] Fase 5 — Progreso
- [ ] Fase 6 — Personal y ajustes
- [ ] Fase 7 — Cinemática y polish
- [ ] Fase 8 — QA y distribución
