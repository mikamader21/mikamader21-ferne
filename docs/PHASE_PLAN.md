# Plan de implementación por fases

Cada fase termina integrada y probada. **No se construyen las 40 pantallas como cascarones vacíos.**

## Entorno de ejecución (permanente)

No hay Mac ni iPhone locales. **Esto no es temporal**: es la restricción del proyecto.

| Entorno | Qué verifica | Vale como aprobación |
|---|---|---|
| Windows local | Lógica de dominio, guards de diseño, integridad del spec, documentación | Sí, para lo que cubre |
| GitHub Actions · runner macOS | Compilación iOS, tests unitarios, UI tests, cobertura, capturas | **Sí. Es la fuente de verdad del build.** |
| Appetize.io (navegador) | Navegación, animaciones, layout, Reduce Motion, VoiceOver | Solo como revisión visual (🟡), nunca ✅ |
| iPhone real | Notificaciones, AlarmKit, sonidos, haptics, rendimiento | Sí. **Imprescindible antes de entregar a Fer.** |

**Ya no se requiere un Mac local en ninguna fase.** Ver `BUILD.md` y `WINDOWS_IOS_PREVIEW.md`.

---

## Fase 0 — Preparación ✅ (con bloqueo de entorno)

**Objetivo:** repositorio, Brain de Claude Code, sistema de diseño y esqueleto verificable.

**Entregado:** estructura modular · `CLAUDE.md` · 16 documentos · 9 rules · 9 agentes · 10 skills · 3 hooks probados · tokens de color/tipografía/espaciado/movimiento · temas mañana/tarde/noche · `SkyScene` · 8 componentes base · dominio puro con `ScoreEngine` · 40 pruebas de dominio · datos de preview · esqueleto de navegación de 4 pestañas · scripts de verificación.

**Criterios verificables**

| Criterio | Cómo se comprueba | Resultado |
|---|---|---|
| El dominio compila y sus pruebas pasan | `bash Scripts/verify-logic.sh` | ✅ 40/40 |
| Los 8 casos de score de §9.4 están cubiertos | ídem | ✅ 8/8 |
| Ningún negro puro, ningún hex fuera de tokens | `bash Scripts/design-guard.sh` | ✅ |
| La capa Domain no importa UI ni persistencia | ídem | ✅ |
| Ninguna pantalla con fondo plano | ídem | ✅ |
| Sin secretos, sin `print(` | ídem | ✅ |
| Los hooks bloquean secretos y comandos destructivos | pruebas manuales de cada hook | ✅ |
| **La app iOS compila** | workflow `iOS CI` | ⬜ **NO VERIFICADO — pipeline no ejecutado** |
| **UI tests pasan** | workflow `iOS CI` | ⬜ **NO VERIFICADO — pipeline no ejecutado** |

> El bloqueo "sin macOS/Xcode" que cerró la Fase 0 queda **resuelto por la Fase 0.5**: la
> compilación pasa a un runner macOS de GitHub Actions. El bloqueo actual ya no es la falta
> de un Mac, sino que el repositorio remoto todavía no existe.

---

## Fase 0.5 — Desarrollo iOS desde Windows 🔵 configurada y validada, pendiente de ejecución remota

**Objetivo:** una cadena reproducible Windows → CI macOS → artifacts → preview en navegador.

**Entregado**

- `.github/workflows/ios-ci.yml` con 5 jobs: `preflight`, `ios`, `screenshot-matrix`, `screenshots`, `gallery`.
- 6 scripts de CI en `Scripts/ci/`, todos con sintaxis validada.
- Infraestructura de capturas: `ScreenshotTests` + `UITestConfiguration` + `ScreenshotFixtures`.
- Matriz de tamaños de iPhone: compacto, estándar y Pro Max.
- 5 artifacts separados, más la galería unificada.
- `docs/VISUAL_QA_MATRIX.md`, `docs/WINDOWS_IOS_PREVIEW.md`, `docs/NOTIFICATIONS_TEST_MATRIX.md`, `docs/DESIGN_REFERENCES.md`.
- Galería local con scripts `.bat` y `.ps1` para Windows.
- `Scripts/verify-spec-integrity.sh` y `Scripts/inventory.sh`.
- Referencias visuales 01, 02 y 03 recibidas, verificadas y analizadas.

**Criterios verificables**

| Criterio | Cómo se comprueba | Resultado |
|---|---|---|
| El workflow es válido | `actionlint` | ✅ sin errores |
| Los scripts de CI no tienen errores de sintaxis | `bash -n` | ✅ 6/6 |
| El generador de galería funciona | ejecutado con y sin capturas | ✅ |
| La integridad del spec se detecta | divergencia simulada y revertida | ✅ detecta y bloquea |
| Las pruebas de dominio siguen en verde | `Scripts/verify-logic.sh` | ✅ 40/40 |
| El guardián de diseño sigue en verde | `Scripts/design-guard.sh` | ✅ 7/7 |
| Las tres referencias existen y coinciden | sha256 y muestreo de píxeles | ✅ 3 de 3 (conjunto completo) |
| Colores atmosféricos aislados de la UI | `design-guard.sh` con violación simulada | ✅ detecta y falla |
| Fuentes con fallback y Dynamic Type | `Scripts/verify-fonts.sh` | ✅ (archivos `.ttf` pendientes) |
| **El pipeline se ejecuta en GitHub** | push al repositorio | ⬜ **PENDIENTE** |
| **Se genera el primer `.app`** | artifact `FERNE-simulator-app` | ⬜ **PENDIENTE** |
| **Appetize muestra la app** | subida manual del zip | ⬜ **PENDIENTE** |

**Estado:** *configurada, documentada y validada estáticamente. Pendiente de primera ejecución
remota en GitHub Actions.*

No se considerará terminada hasta que: el workflow se ejecute, el proyecto se genere, SwiftUI
compile, pasen los tests, se genere `FERNE.app`, se produzcan capturas, se descarguen los
artifacts y el build se abra en Appetize.

**Bloqueos abiertos**

1. **GitHub CLI sin autenticar.** La creación del repositorio está autorizada desde el
   6 de agosto de 2026, pero requiere `gh auth login` en la máquina de Windows. El entorno
   de Claude está aislado de esas credenciales por diseño.
2. Archivos `.ttf` de las fuentes pendientes de descarga (la app funciona con el fallback).

**Preflight completado el 6 de agosto de 2026:** secretos limpios, 40/40 pruebas, Design Guard
8/8, integridad del spec OK, AlarmKit compatible, `actionlint` sin errores, simulacro de commit
con 155 archivos y nada prohibido.

---

## Fase 1 — Núcleo funcional

**Objetivo:** que una actividad exista de verdad, se guarde y sobreviva al reinicio.

- `@Model` de SwiftData para `Activity` + esquema versionado y `SchemaMigrationPlan`.
- Proyección `toSnapshot()` hacia el dominio.
- `ActivityRepository` con crear, editar, completar, reprogramar, cancelar.
- `DateService` (día natural, semana, conflictos de horario).
- Pantallas 33 (Detalle de actividad) y 34 (Reprogramar).
- Conectar `HomeView` y `ProgressView` a datos reales en lugar de `PreviewData`.

**Criterios de aceptación**

1. Crear una actividad, cerrar la app, reabrirla y que siga ahí (prueba automatizada + comprobación manual).
2. Completar cambia el score diario en la misma sesión.
3. Reprogramar registra `rescheduledFrom` y no baja el score.
4. Los ocho casos de §9.4 siguen en verde sobre datos reales de SwiftData.
5. La app funciona con el iPhone en modo avión.
6. Existe la migración v1 y su prueba, aunque todavía no haya nada que migrar.

**Dónde se verifica:** el código y sus pruebas de dominio, en Windows. La compilación, los
tests en simulador y las capturas, en el workflow `iOS CI`. La Fase 1 no se declara terminada
sin **build verde, tests verdes, artifact `.app`, capturas e informe de diferencias visuales**
contra `docs/design-references/`.

---

## Fase 2 — Inicio y agenda

Pantallas 01, 02, 03, 04, 06, 07, 08, 09, 10.
Splash cinematográfico completo, onboarding, permisos en contexto, Inicio real con cuenta regresiva, agenda día/semana/mes, menú Agregar y formulario de recordatorio.

**Aceptación:** crear un recordatorio desde el FAB y verlo aparecer en Inicio y en las tres vistas de agenda. Arrastrar para reprogramar con confirmación.

---

## Fase 3 — Categorías

Pantallas 11–23. Comidas, gym, TikTok Live, lectura, pagos, rutinas y hora de dormir.

**Aceptación:** cada categoría crea actividades que respetan su modelo. Sin calorías, peso ni medidas en ninguna parte. Los horarios de live propuestos no cruzan comidas, gym, lectura ni descanso.

---

## Fase 4 — Notificaciones

Pantallas 24 y 25. `UserNotifications`, AlarmKit con fallback, sonidos seleccionables con preview, acciones y centro de salud.

**Aceptación:** las 13 pruebas de nivel 1 en verde en CI y las 7 de nivel 2 revisadas en
Appetize. Cero duplicados tras editar dos veces. La UI refleja el permiso real.

**No puede declararse terminada** hasta ejecutar las 12 pruebas de nivel 3 en el iPhone de Fer.
Queda en *"completa a falta de validación en dispositivo"*. Ver `NOTIFICATIONS_TEST_MATRIX.md`.

**Bloqueo conocido:** faltan los seis archivos de audio.

---

## Fase 5 — Progreso

Pantallas 05, 36, 37, 38, 39, 40. Score con Swift Charts, resumen diario, recomendaciones explicables y celebración semanal.

**Aceptación:** la pantalla 38 explica cada componente del score con su peso. Toda recomendación sigue el formato de cuatro partes y pasa `ScoreLanguage`.

---

## Fase 6 — Personal y ajustes

Pantallas 26–32. Para mí, registro del día, perfil completo, privacidad, Face ID, iCloud e IA opcional preparada pero no obligatoria.

**Aceptación:** exportar y eliminar datos funcionan de verdad. Sin claves en el repositorio. La app funciona íntegra con la IA desconectada.

---

## Fase 7 — Cinemática y polish

Pantalla 35. Amanecer, tarde y noche pulidos, Lottie si se aprueba, haptics y microinteracciones.

**Aceptación:** con Reduce Motion las escenas se simplifican **sin perder sol ni luna**.

Aquí se cierran los elementos P2 del backlog visual (`VISUAL_BACKLOG.md`): tarjetas de vidrio,
malla de color del Splash, píldora de pestaña activa y posición del halo.

**Los 60 fps no pueden medirse en Appetize** (transmite vídeo). Requieren Instruments en un
dispositivo: queda como NO VERIFICADO hasta entonces.

---

## Fase 8 — QA y distribución

Pruebas completas, rendimiento, accesibilidad, dispositivo real, firma y TestFlight.

**Aceptación:** los doce criterios de §17. Quality gate completo en verde, sin NO VERIFICADO.
