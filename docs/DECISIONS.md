# Registro de decisiones

Formato: qué se decidió, por qué, qué se descartó y qué coste tiene.

---

## Fase 0 — 6 de agosto de 2026

### D-001 · El dominio es Foundation puro

**Decisión:** `Domain/` no importa SwiftUI, SwiftData ni UIKit. Verificado por `design-guard.sh` y por `verify-logic.sh`.

**Por qué:** permite compilar y probar el motor de score y todas las reglas de fecha **sin Xcode y sin simulador**. En este entorno (Linux, sin macOS) fue la diferencia entre entregar 40 pruebas realmente ejecutadas y entregar código sin verificar.

**Descartado:** poner las reglas directamente sobre los `@Model` de SwiftData. Habría hecho imposible probar el score sin levantar un contenedor.

**Coste:** duplicación de campos entre `ActivitySnapshot` y el futuro `@Model Activity`, más una proyección que mantener.

---

### D-002 · XcodeGen en lugar de un `.xcodeproj` versionado

**Decisión:** el proyecto se genera desde `project.yml`. `FERNE.xcodeproj` está en `.gitignore`.

**Por qué:** un `project.pbxproj` escrito a mano fuera de Xcode es frágil y propenso a corromperse. `project.yml` es legible, revisable y no genera conflictos de merge. Además permite definir el proyecto completo desde un entorno sin Xcode, que es exactamente la situación actual.

**Descartado:** generar el `.pbxproj` manualmente (alto riesgo de un proyecto que no abre) y crear el proyecto a mano en Xcode (imposible aquí).

**Coste:** una dependencia de herramienta de desarrollo (`brew install xcodegen`). No entra en el binario de la app.

---

### D-003 · Serif del sistema en lugar de una fuente de terceros

> **⚠️ SUPERADA por D-023 el 6 de agosto de 2026.**
> Se conserva por trazabilidad. La decisión se tomó **sin conocer la licencia** de las fuentes
> del diseño. Al recibir `docs/design-references/DESIGN-TOKENS.md` se identificaron Libre
> Caslon Text y Hanken Grotesk, ambas con SIL Open Font License 1.1, que permite incrustarlas
> en una app comercial. Desaparecido el motivo, desaparece la decisión.

**Decisión (histórica):** los encabezados usan `Font.system(design: .serif)`.

**Por qué:** la especificación pide "serif elegante con licencia apta para distribución **o tipografía del sistema equivalente**". La serif del sistema no tiene coste de licencia, escala con Dynamic Type sin trabajo extra y no añade peso al bundle.

**Descartado:** incorporar una serif comercial sin tener la licencia confirmada.

**Coste:** menos personalidad tipográfica. Si más adelante se aprueba una fuente con licencia, solo cambia `FerneTypography.swift`.

---

### D-004 · Los días sin datos no arrastran el score semanal

**Decisión:** el componente diario del score semanal promedia solo los días con actividades evaluables.

**Por qué:** si es miércoles, contar jueves a domingo como 0% daría un score falso y desalentador. La especificación exige lenguaje que oriente y no castigue; un número engañosamente bajo castiga.

**Descartado:** promediar los siete días siempre.

**Coste:** una semana con un solo día perfecto marca 100%. Se mitiga mostrando cuántos días tienen datos.

---

### D-005 · Una categoría no programada devuelve 100, no 0

**Decisión:** si no hay actividades de gym en la semana, el componente de compromisos vale 100.

**Por qué:** no programar gym no es un incumplimiento; no hay nada que incumplir. Puntuar 0 convertiría el score en un juicio sobre lo que Fer "debería" hacer, que es precisamente lo prohibido en §9.3.

**Descartado:** puntuar 0 o excluir el componente y renormalizar los pesos (rompería la ponderación fija 40/20/20/20 de la especificación).

**Coste:** el score no distingue "no lo programé" de "lo cumplí todo". La pantalla 38 debe mostrarlo explícitamente.

---

### D-006 · La franja horaria vive en el dominio, el aspecto en el design system

**Decisión:** `DayPhase` (Foundation puro) decide **cuándo**; `FerneTheme` (SwiftUI) decide **cómo se ve**.

**Por qué:** los límites horarios (05:00, 12:00, 19:00) son una regla de producto y deben tener pruebas. Con SwiftUI de por medio no podrían ejecutarse aquí.

**Coste:** dos tipos donde parecería bastar uno.

---

### D-007 · Reduce Motion detiene el movimiento, nunca elimina la escena

**Decisión:** con `accessibilityReduceMotion`, cielo, astro, halo, nubes y estrellas siguen dibujándose; solo cesan las animaciones.

**Por qué:** la especificación prohíbe los fondos planos sin excepción y pide respetar Reduce Motion. Ambas cosas son compatibles: lo que molesta a quien activa ese ajuste es el movimiento, no el color.

---

### D-008 · Posiciones de estrellas y partículas deterministas

**Decisión:** coordenadas fijas en lugar de `random()`.

**Por qué:** §14.3 exige comparar capturas entre tamaños de texto y entre día y noche. Con posiciones aleatorias, dos capturas de la misma pantalla nunca coincidirían y la comparación visual sería imposible.

**Coste:** menos variedad orgánica. Se compensa con desfases de animación distintos por partícula.

---

### D-009 · No se crearon archivos de audio placeholder

**Decisión:** los seis sonidos están declarados en `SoundLibrary`, pero no existe ningún `.caf`. `FerneSound.isAvailable` consulta el bundle de verdad y Perfil muestra "Pendiente".

**Por qué:** un tono generado sintéticamente no es el sonido aprobado. Incluirlo daría la impresión de que esa parte está resuelta cuando no lo está, y la especificación prohíbe simular entregas.

**Coste:** los sonidos no suenan hasta que existan los archivos. Es la situación real, y ahora es visible en la propia app.

---

### D-010 · Ninguna dependencia añadida al binario

**Decisión:** cero paquetes de terceros en el target de la app. Lottie **no** se ha incorporado.

**Por qué:** la política de §12 pide preferir frameworks de Apple y justificar cada librería. `SkyScene` en SwiftUI nativo cumple con lo que pide la escena; añadir Lottie ahora sería peso sin beneficio demostrado.

**Herramientas de desarrollo (fuera del binario):** XcodeGen (D-002), SwiftLint y SwiftFormat (explícitamente permitidas en §12.2).

---

## Conflictos con la especificación

Ninguno. Todas las decisiones anteriores desarrollan la especificación en puntos que dejaba abiertos; ninguna la contradice.

## Bloqueos registrados

| # | Bloqueo | Registrado |
|---|---|---|
| 1 | Sin macOS ni Xcode: la app iOS no puede compilarse ni ejecutarse en este entorno | Fase 0 |
| 2 | No se recibieron las referencias visuales aprobadas | Fase 0 |
| 3 | No existen los seis archivos de audio | Fase 0 |
| 4 | Team ID, bundle ID definitivo y dispositivo objetivo sin confirmar | Fase 0 |

---

## Migración de ubicación — 6 de agosto de 2026

### D-011 · El proyecto vive en `Documents\Claude\Projects\FERNE`

**Decisión:** la ruta oficial y única del proyecto es
`C:\Users\MIKA\Documents\Claude\Projects\FERNE`.

**Por qué:** la carpeta de salida de la sesión es temporal y se limpia entre sesiones. Un
proyecto que va a durar ocho fases no puede vivir ahí.

**Cómo se hizo:** copia completa y verificación por checksum MD5, archivo por archivo.

**Corrección del recuento.** El informe de migración citó dos cifras (125 y 126) porque se
midió en dos momentos distintos. Aclaración, con el criterio único que hoy aplica
`Scripts/inventory.sh`:

| Momento | Archivos | Qué cambió |
|---|---|---|
| Copia y verificación por checksum | **125** | Estado copiado. Los 125 coincidieron byte a byte. Incluye `docs/design-references/README.md`, que ya existía. |
| Tras añadir `docs/FERNE_MASTER_SPEC.md` | **126** | Cifra citada en el informe final. |
| Tras recibir tus referencias y completar la Fase 0.5 | ver `Scripts/inventory.sh` | 9 archivos entregados por ti + los creados en la Fase 0.5 |

Ninguna de las dos cifras era incorrecta; faltaba decir a qué momento correspondía cada una.

**Aclaraciones concretas:**

- `UBICACION-DEL-PROYECTO.txt` se creó **después** de la verificación y **fuera** de la carpeta
  del proyecto (queda en `outputs\`, hermana de `outputs\FERNE\`). Nunca entró en ninguno de
  los dos recuentos.
- `docs/design-references/README.md` **sí** se contó: existía antes de la copia y forma parte
  del proyecto.
- No se excluyó ningún archivo temporal en aquella comparación. El criterio de exclusión
  (`.git/`, `build/`, `artifacts/`, `*.xcodeproj/`) es el que aplica `Scripts/inventory.sh` de
  aquí en adelante.

**Cifra oficial de ahora en adelante:** la que produce `bash Scripts/inventory.sh`. Es el
único criterio válido; cualquier recuento manual queda obsoleto en cuanto se añade un archivo.

Los checksums verificados en la migración **no se han recalculado ni alterado**: siguen siendo
válidos para los 125 archivos de aquel momento.

La carpeta temporal **no se borró**: queda como respaldo congelado.

**Consecuencia:** cualquier edición posterior ocurre solo en la ruta oficial. Si la copia
temporal y la oficial divergen, la oficial es la correcta.

---

### D-012 · Dos archivos de especificación, con papeles distintos

**Decisión:** conviven dos archivos idénticos en `docs/`:

| Archivo | Papel |
|---|---|
| `FERNE_MASTER_SPEC.md` | **Original v1.0 congelado.** Copia byte a byte del documento entregado. No se edita nunca. |
| `MASTER_SPEC.md` | **Copia de trabajo.** Es la ruta que exige §3.4 y a la que apunta `CLAUDE.md`. |

**Por qué:** §3.4 impone la ruta `docs/MASTER_SPEC.md` y todo el sistema de reglas y agentes
la referencia. A la vez, conservar el original con su nombre permite detectar en cualquier
momento si la copia de trabajo fue alterada.

**Verificación:** hoy `md5 = 81021215390d43a17b137d393e291dac` en ambos, y también en el
archivo original tal como se subió.

**Riesgo aceptado:** si alguien edita solo uno, divergen. Mitigación: el original no se toca
jamás y, ante una diferencia, **gana el original**.

---

### D-013 · Entorno de desarrollo: Windows + CI macOS + Appetize

**Decisión:** el proyecto asume de forma permanente que no hay Mac ni iPhone locales.
La compilación iOS ocurre en un runner macOS de GitHub Actions y la vista previa
interactiva en Appetize.io.

**Por qué:** es la restricción real del entorno de trabajo, no una limitación temporal.
Fingir que hay un Mac disponible produciría un plan que nunca podría ejecutarse.

**Lo que NO cambia:** SwiftUI nativo, arquitectura, dominio puro, cero dependencias en el
binario. No se sustituye nada por React, React Native, Expo, Flutter ni web.

**Lo que sí cambia:** el `Makefile` deja de ser la vía principal de verificación; pasa a
serlo el workflow. Y hay una categoría de pruebas —notificaciones, AlarmKit, sonidos,
haptics— que **ningún** entorno remoto puede aprobar. Quedan explícitamente pendientes de
un iPhone físico.

---

## Fase 0.5 — 6 de agosto de 2026

### D-014 · La compilación iOS vive en GitHub Actions, no en un Mac

**Decisión:** el workflow `.github/workflows/ios-ci.yml` sobre un runner `macos-15` es la
única fuente de verdad sobre si FERNÉ compila y si sus pruebas pasan.

**Por qué:** no hay Mac. Es una restricción permanente del proyecto, no un contratiempo. Un
plan que dependa de un Mac local nunca podría ejecutarse.

**Descartado:** MacStadium y servicios de Mac en la nube por suscripción (coste recurrente
sin necesidad demostrada); cambiar de tecnología (rompería toda la especificación).

**Coste:** el ciclo de iteración pasa de segundos a minutos, y los minutos macOS se facturan
x10 en repositorios privados. Mitigación: `preflight` corre en Linux y aborta antes de gastar
un runner caro; la matriz de tres iPhones solo se activa en `main` o a petición.

---

### D-015 · El simulador se resuelve en tiempo de ejecución

**Decisión:** `Scripts/ci/resolve-simulator.sh` consulta `xcrun simctl list devices available`
y elige el mejor iPhone disponible, en lugar de fijar `iPhone 16 Pro`.

**Por qué:** las imágenes de los runners cambian sin aviso. Un destino fijo rompe el pipeline
el día que Apple retira ese modelo, y el error resultante no dice nada útil.

**Preferencias, en orden:** el solicitado → cualquier iPhone "Pro" no Max → cualquier iPhone,
siempre en la versión de iOS más alta. Se usa el **UDID**, no el nombre, porque el nombre se
repite entre runtimes. El modelo elegido queda registrado en el log y en el resumen.

---

### D-016 · Las capturas se controlan por argumento de lanzamiento

**Decisión:** `UITestConfiguration` lee argumentos (`-FERNEPhase`, `-FERNEFixture`,
`-FERNESkipSplash`, `-FERNEReduceMotion`) y solo se activa bajo `-FERNEUITest 1`.

**Por qué:** desde Windows las capturas son la única forma de ver FERNÉ. Para servir como QA
visual deben ser **deterministas**: dos capturas de la misma pantalla tienen que ser idénticas.
Si el tema dependiera del reloj del simulador, sería imposible comparar nada.

`ScreenshotFixtures` ancla todo al lunes 3 de agosto de 2026.

**Riesgo detectado y corregido durante la implementación:** la primera versión aplicaba
`.environment(\.accessibilityReduceMotion, ...)` siempre, lo que en un build normal habría
pisado el ajuste real de iOS con `false` — es decir, FERNÉ habría dejado de respetar Reduce
Motion para quien lo tiene activado. Ahora la sobrescritura solo ocurre cuando el UI test la
pide explícitamente.

**Limitación honesta:** `-FERNEReduceMotion 1` fuerza el comportamiento a nivel de app, no el
ajuste del sistema. No demuestra conformidad real. Eso se verifica activando el ajuste en
Appetize o en un dispositivo.

---

### D-017 · La galería muestra imágenes, no reconstruye la app

**Decisión:** `Scripts/build-gallery.py` genera un HTML estático que solo enlaza PNG que ya
existen: tus referencias y las capturas del simulador.

**Por qué:** la tentación evidente sería maquetar FERNÉ en HTML para verla rápido en Windows.
Sería un error: se convertiría en una segunda implementación que diverge de la real, y daría
una falsa sensación de progreso. La galería lleva un aviso permanente de que no es la app.

**Coste:** no se puede interactuar. Para eso está Appetize.

---

### D-018 · Verificación de integridad de los documentos maestros

**Decisión:** `Scripts/verify-spec-integrity.sh` compara los sha256 de
`docs/FERNE_MASTER_SPEC.md` (congelado) y `docs/MASTER_SPEC.md` (operativo) contra
`.spec-integrity`, y **bloquea** si divergen sin decisión registrada.

**Por qué:** D-012 aceptó tener dos copias con el riesgo de que divergieran. Una regla escrita
en un documento no impide nada; un script que devuelve código de salida 1, sí.

**Comportamiento:** nunca sobrescribe. Si el original cambia, avisa de que debe recuperarse.
Si la copia diverge sin autorización, muestra el `diff` y recuerda que **gana el original**.

**Probado:** se introdujo una línea intrusa en la copia operativa, el script la detectó,
mostró la diferencia y devolvió 1. Se revirtió y volvió a OK.

---

### D-019 · Las referencias no se copian al código fuente

**Decisión:** los PNG de `docs/design-references/` se quedan en documentación. No entran en
`Assets.xcassets`.

**Por qué:** son material de **comparación**. FERNÉ dibuja sus escenas con SwiftUI de forma
procedural: un PNG de 1600 px como fondo rompería Dynamic Type, el rendimiento y el
redimensionado entre iPhone compacto y Pro Max.

Además, `02-home-approved.png` contiene un **cielo fotográfico** y un **avatar de persona**.
Ninguno de los dos puede entrar al binario sin verificar su licencia.

**Si en la Fase 7 se demuestra que hace falta un asset:** solo el elemento concreto, exportado
a HEIC/PNG-8 a 2x y 3x, con licencia confirmada y el peso registrado. Procedimiento en
`docs/design-references/README.md`.

---

### D-020 · Conflicto de color en el Splash · SIN RESOLVER

**Situación:** `01-splash-approved.png` contiene cian (`#69E6FC`, hue 188°) e índigo
(`#B0A6EA`, hue 248°). Confirmado por muestreo de píxeles y por el `code.html` de origen,
que declara `hsla(189,100%,56%)` y `hsla(242,100%,70%)`.

`MASTER_SPEC.md` §4.2 no incluye ningún color frío. §4.5 describe la mañana como
"rosa/melocotón" y la noche como "ciruela, rosa oscuro y lavanda".

**Decisión: ninguna.** §0.10 de la especificación obliga a detenerse y pedir aprobación cuando
algo la contradice. Las tres opciones, con su coste, están en `DESIGN_REFERENCES.md` §2.

**Mientras tanto:** el Splash queda como está y la pantalla 01 no puede aprobarse.

---

### D-021 · Libre Caslon Text y Hanken Grotesk · PENDIENTE DE APROBACIÓN

**Situación:** `DESIGN-TOKENS.md` especifica esas dos fuentes. La decisión D-003 optó por la
serif del sistema **por no conocer la licencia**. Ahora se sabe: ambas son de Google Fonts con
**SIL Open Font License 1.1**, que permite incrustarlas en una app comercial.

**Propuesta:** adoptar Libre Caslon Text para titulares en la Fase 7. Mantener SF Pro para el
cuerpo (Hanken Grotesk aportaría poco y añadiría ~200 KB al bundle).

**Requiere tu aprobación** porque añade recursos al binario y `CLAUDE.md` prohíbe hacerlo sin
justificación aceptada.

---

## Correcciones aprobadas — 6 de agosto de 2026

### D-022 · La paleta tiene dos grupos: funcionales y atmosféricos

**Decisión (de Mika):** los colores del Splash se conservan **exactamente como aparecen en la
referencia aprobada**, incluidos el cian `#69E6FC` y el índigo `#B0A6EA`.

**Por qué no contradicen la identidad:** son colores **atmosféricos**, no de interfaz. Un
cielo real tiene azules; una app cálida no deja de serlo por tener un amanecer con cian en lo
alto. Lo que definiría la identidad sería usarlos en un botón, y eso queda prohibido.

**La paleta se reorganiza en dos grupos con reglas distintas:**

| Grupo | Colores | Dónde |
|---|---|---|
| **Funcionales** | rosas, coral, dorado, ciruela, blanco cálido, verde de completado, ámbar de atención | Botones, texto, tarjetas, estados, navegación, formularios |
| **Atmosféricos** | cian cielo, lavanda, índigo suave, rosa de amanecer, melocotón, ciruela nocturno | Splash, cielos, transiciones, reflejos, amanecer, noche, fondos cinematográficos, partículas, halos |

**Regla de prioridad:** cuando la referencia visual y la lista inicial de §4.2 difieran de
forma demostrable, **manda la referencia**.

**Cómo se hace cumplir:** `Scripts/design-guard.sh` falla si un color atmosférico aparece
fuera de `DesignSystem/Scenes/` o `DesignSystem/Theme/`. Probado introduciendo la violación a
propósito en `HomeView`: el guardián la detectó y falló. Revertido.

**Aplicado en:** `FerneColor` (7 tokens atmosféricos + `brandMagenta`), `FerneTheme` (las tres
franjas), `SkyScene` (partículas alternadas).

---

### D-023 · Libre Caslon Text y Hanken Grotesk (sustituye a D-003)

**Decisión (de Mika):** se incorporan ambas fuentes.

| Familia | Uso |
|---|---|
| **Libre Caslon Text** | Logotipo, saludos, titulares editoriales |
| **Hanken Grotesk** | Textos de marca, subtítulos, contenido general |
| **SF Pro / sistema** | Controles nativos muy pequeños y casos de accesibilidad |

Ambas con **SIL Open Font License 1.1**, que permite incrustarlas en una app comercial.

**Implementado:**

- `FerneFont` reescrito: cada estilo usa `.custom(_:size:relativeTo:)` para que **escale con
  Dynamic Type**, que es donde fallan casi todas las integraciones de fuentes personalizadas.
- **Fallback automático:** si un `.ttf` no está registrado, cae a la fuente del sistema con el
  mismo diseño (serif o sans). La app nunca se rompe por una fuente ausente; solo cambia su
  carácter. `FerneFont.missingFonts` permite diagnosticarlo.
- `Info.plist` declara las 7 fuentes en `UIAppFonts`.
- `FERNE/Resources/Fonts/` con su `README.md` y `Licenses/`.
- `Scripts/verify-fonts.sh`: comprueba archivos, licencias, peso total (falla por encima de
  600 KB), tamaños sospechosos, presencia del fallback y uso de `relativeTo:`.

**Pendiente:** los `.ttf` no se han descargado. No se introducen binarios sin que puedas
verificar su procedencia. Instrucciones en `FERNE/Resources/Fonts/README.md`.

**Peso añadido al binario:** 0 KB hoy. Se registrará al añadir los archivos. Límite aceptado:
600 KB; por encima se reducen cortes.

**Reglas:** no modificar los archivos de fuente, no usar pesos no incluidos, las licencias
viajan en el bundle. Pendiente de verificar en simulador: tildes, ñ, ¿, ¡ y la **É de FERNÉ**,
que es el carácter crítico del logotipo.

---

### D-024 · La escena nocturna se deriva, no se espera

**Decisión (de Mika):** no existe referencia nocturna y no hace falta. La noche se deriva
profesionalmente del mismo sistema visual.

**Cómo se derivó:**

| Franja | Composición |
|---|---|
| Mañana | Rosa de amanecer → cloudPink → **cian 18 %** → melocotón → ivoryRose. Sol suave, nubes, luz cálida, destellos. |
| Tarde | **Cian 12 %** → melocotón → coral → cloudPink → ivoryRose. Mayor luminosidad, sol alto, reflejos. |
| Noche | deepPlum → secondaryPlum → **índigo 45 %** → ciruela nocturno → **lavanda 70 %** → softPink. |

**Decisiones concretas de la noche:**

- **Luna cálida con halo dorado.** Una luna blanca fría habría convertido la escena en otra
  app. El halo usa `sunGold`, no blanco.
- **Nubes rosadas oscuras**, no grises: `softPink` al 32 %.
- **Partículas alternadas** blancas y doradas (`particlePalette`).
- **El rosado nunca desaparece** del degradado: la última parada sigue siendo `softPink`.

**Prohibido, y verificado por el guardián donde es automatizable:** negro puro, azul
corporativo, cielo frío genérico, estética espacial oscura, neón, perder los tonos rosados,
eliminar las tarjetas cálidas.

**Criterio de aceptación:** la noche debe sentirse como el mismo universo visual, no como otra
aplicación. Se verificará con las capturas nocturnas del pipeline.

---

### D-025 · Las tres referencias son la autoridad visual de las 40 pantallas

**Decisión (de Mika):** nunca existió una cuarta imagen. Las tres recibidas son oficiales y
**suficientes**.

**Qué define cada una, para toda la app:**

- **Splash** → identidad cinematográfica, gradientes, luz, partículas, profundidad, movimiento.
- **Inicio** → organización visual, tarjetas, jerarquía, saludo, escena, agenda, iconografía.
- **Progreso** → indicadores, gráficas, círculos, score, estados, recomendaciones.

**Consecuencia práctica:** no hace falta una imagen aprobada por pantalla antes de
implementarla. `visual-guardian` evalúa cada pantalla nueva contra el **sistema derivado**:
identidad, colores, tipografía, radios, tarjetas, profundidad, iconografía, iluminación,
lenguaje visual y la misma sensación alegre, viva y cinematográfica.

**Eliminado del proyecto:** todo requisito, bloqueo y mención de una cuarta referencia.
Verificado: cero ocurrencias en documentación, scripts, agentes, skills y quality gates.
`Scripts/ci/check-required-files.sh` ahora **falla** si falta cualquiera de las tres, en lugar
de avisar de una cuarta que no existe.

**Criterio del guardián:** si una pantalla parece de otra aplicación, se rechaza aunque
respete la paleta token por token.

---

### D-026 · Las 25 diferencias visuales son un backlog, no una corrección masiva

**Decisión:** las diferencias entre las referencias y la implementación se registran en
`docs/VISUAL_BACKLOG.md`, priorizadas P0–P3, con pantalla, referencia, estado actual, acción,
fase y estado.

**Por qué no se corrigen todas ahora:** no hay forma de comprobar el resultado. Cambiar 25
elementos sin compilar produciría 25 suposiciones. Los P0 se aplicaron porque afectan a todas
las pantallas y arrastrarlos habría obligado a rehacer treinta vistas después.

**Estado hoy:** 4 elementos en 🟡 (código cambiado, resultado no visto), 21 en ⬜.
**Ninguno en ✅**, porque el pipeline no se ha ejecutado nunca.

**Regla:** un elemento solo pasa a ✅ tras compararse con la referencia en una captura real
del pipeline.

---

## Preparación de la primera ejecución — 6 de agosto de 2026

### D-027 · AlarmKit se protege antes de escribir una línea de su código

**Decisión:** crear `FERNE/Services/Notifications/AlarmCapability.swift` y
`Scripts/verify-alarmkit.sh` **ahora**, aunque AlarmKit no se implemente hasta la Fase 4.

**Por qué:** AlarmKit es reciente y su disponibilidad varía entre versiones de Xcode y de iOS.
Un `import AlarmKit` sin proteger convierte cualquier runner con un SDK distinto en un build
roto, con un mensaje de error que no explica la causa. Establecer el patrón antes de que
exista el código es más barato que arreglar quince ficheros en la Fase 4.

**Tres capas, y las tres hacen falta:**

1. `#if canImport(AlarmKit)` — el SDK del runner puede no traerlo.
2. `if #available(iOS 26.0, *)` — el framework puede existir en el SDK pero no en el iOS del
   dispositivo. Compilar no es lo mismo que poder ejecutar.
3. Fallback completo a `UserNotifications` — aunque las dos anteriores pasen, el permiso
   puede estar denegado o Apple puede no haber aprobado el entitlement.

**Decisión de producto incluida:** solo `Priority.esencial` (despertar y dormir) opta a alarma
prominente. Convertir un recordatorio de lectura en una alarma que no se puede silenciar sería
hostil, y la especificación pide amabilidad.

**Entitlements:** `com.apple.developer.alarmkit` se conserva. Requiere aprobación de Apple,
pero con `CODE_SIGNING_ALLOWED=NO` no se valida, así que no bloquea el build de simulador. Si
algún día bloquea el archivado, se separa en un entitlements distinto para Release.

**Verificado:** el script pasa las 5 comprobaciones. Está en el quality gate y en el job
`preflight` del workflow.

---

### D-028 · Seis fuentes, no nueve

**Decisión:** `UIAppFonts` declara únicamente los seis cortes que `FerneFont` usa de verdad.

Se descartó `LibreCaslonText-Italic.ttf`: ninguna vista la usa. Cada corte añade peso al
binario, y declarar fuentes "por si acaso" es la vía habitual para que una app engorde sin
que nadie sepa por qué.

| Archivo | Lo usa |
|---|---|
| `LibreCaslonText-Regular` | `sectionTitle` |
| `LibreCaslonText-Bold` | `display`, `greeting`, `scoreNumber` |
| `HankenGrotesk-Regular` | `body`, `secondary` |
| `HankenGrotesk-Medium` | `meta` |
| `HankenGrotesk-SemiBold` | `cardTitle`, `button` |
| `HankenGrotesk-Bold` | `labelCaps` |

**Procedencia:** solo Google Fonts o el repositorio oficial de cada familia. Nada de
agregadores de terceros.

**`verify-fonts.sh` devuelve 0 con los archivos ausentes**, a propósito: la falta de fuentes
no puede romper el build mientras el fallback funcione. Se endurecerá en la Fase 7.

---

### D-029 · Claude no puede crear el repositorio, y eso está bien

**Situación:** la creación del repositorio quedó autorizada, pero el entorno de trabajo de
Claude es un sandbox Linux aislado de la máquina de Windows. No tiene `gh`, ni credenciales,
ni claves SSH, ni acceso a las de Mika.

**Decisión: no se intenta rodear ese aislamiento.** Ni pidiendo un token por chat, ni
instalando `gh` en el sandbox, ni ninguna otra vía. El comando `gh auth login` se ejecuta en
Windows, con flujo por navegador, y la credencial nunca sale de esa máquina.

**Por qué importa:** un token pegado en un chat queda en el historial de la conversación. El
flujo por navegador no expone nada.

**Lo que sí se hizo:** dejar el camino preparado y verificado.

- `.gitignore` reforzado: `*.p8`, `*.pem`, `*.key`, `*.cer`, `*.pfx`, `artifacts/`,
  `*.xcresult/`, `outputs/`.
- Simulacro de commit con un repositorio temporal **fuera** del proyecto: 155 archivos,
  3,7 MB, cero archivos prohibidos. La ruta oficial no tiene `.git`.
- `Scripts/conectar-github.bat`: ejecuta el preflight, muestra qué se versionará, **pide
  confirmación**, crea el repositorio privado y hace push. Sin force push ni reescritura.

**Observación sobre el tamaño:** 3,2 de los 3,7 MB son PNG de referencia, y la mitad está
duplicada (los originales en `1/`, `2/`, `3/` y las copias con nombre canónico tienen el mismo
contenido). Se conserva así porque pediste no tocar los originales. Si el peso del repositorio
llega a molestar, se resuelve dejando solo los nombres canónicos: son byte a byte idénticos.

---

### D-030 · Política explícita de finales de línea

**Origen:** al preparar el primer commit, Git avisó de que convertiría LF a CRLF. Mika detuvo
el proceso antes de confirmarlo. Fue la decisión correcta.

**Qué habría roto, en concreto:**

1. **Los scripts Bash.** Un `.sh` con CRLF hace que el runner Linux intente ejecutar
   `/usr/bin/env bash\r` y falle con `bad interpreter: ... ^M`. El mensaje no menciona los
   finales de línea, así que se pierde mucho tiempo buscando en el sitio equivocado.
2. **El workflow.** Los bloques `run:` heredarían el `\r` y fallarían de la misma forma.
3. **Los checksums.** El mismo contenido con distinto final de línea produce un sha256
   distinto. `verify-spec-integrity.sh` habría bloqueado el proyecto denunciando una
   divergencia de la especificación que no existía. El sistema de integridad se habría
   convertido en una fuente de falsos positivos.

**Decisión:** `.gitattributes` explícito en la raíz.

| Grupo | Política | Motivo |
|---|---|---|
| `.sh`, `.yml`, `.swift`, `.md`, `.py`, `.plist`, `.entitlements`, `Makefile`, `.spec-integrity` | `text eol=lf` | Los consume Linux y macOS |
| `.bat`, `.cmd`, `.ps1` | `text eol=crlf` | Los ejecuta Windows |
| `.png`, `.jpg`, `.ttf`, `.otf`, `.caf`, `.wav`, `.zip`, `.p12`, `.p8` | `binary` | Una sola conversión los corrompe irreversiblemente |

**Además:** `core.autocrlf false`, para que mande `.gitattributes` y no la configuración
global de la máquina.

**Los ejecutables de Windows se guardaron ya en CRLF** en el árbol de trabajo. Así no queda
ni un aviso de conversión: lo que hay en disco es exactamente lo que Git materializará.

**Verificado, no supuesto:**

- Antes: 3 avisos de conversión. Después: **cero**.
- 16 de 16 scripts `.sh` en LF, en índice y en árbol.
- `ios-ci.yml` en LF.
- `.bat` y `.ps1` con `i/lf w/crlf`: LF en el repositorio, CRLF en Windows.
- Los 6 PNG con `i/-text w/-text`: Git no los toca.
- **Los checksums de la especificación no cambiaron**: siguen en
  `8c3724a97c81d6c0619b7f0df023c6dd…`
- Comparación archivo a archivo entre el árbol y los blobs del índice: **151 archivos de
  texto idénticos ignorando saltos de línea, 6 binarios idénticos byte a byte, 0 alterados**.

**Añadido:** `Scripts/verify-line-endings.sh`, que comprueba la política, detecta CRLF en
archivos que deben ser LF, revisa que ningún shebang lleve `\r` y confirma que los binarios
están protegidos. Corre en el quality gate, en el job `preflight` del workflow y en
`conectar-github.bat` antes de cualquier `git add`.

**Nota de método:** toda esta verificación se hizo con un `GIT_DIR` temporal **fuera** del
proyecto. La ruta oficial sigue sin `.git`, y no se ha hecho ningún commit.

---

### D-031 · La noche empieza a las 18:00, no a las 19:00

**Decisión (de Mika):** las franjas pasan a ser 05:00–11:59 mañana, 12:00–17:59 tarde,
18:00–04:59 noche.

**Contradice `MASTER_SPEC.md` §4.5**, que fijaba la noche a las 19:00. Se registra aquí
porque §0.10 obliga a documentar cualquier desviación de la especificación. El motivo es
observacional: a las 18:00 la luz ya no acompaña una escena diurna.

**Además:** el proveedor de franja pasa a `Calendar.autoupdatingCurrent`. Si Fer viaja o
cambia la zona horaria del iPhone, la escena sigue su hora local sin reiniciar la app.
`ThemeController` programa un único despertar en la frontera siguiente en lugar de sondear
el reloj, y lo recalcula al volver del segundo plano y ante `NSSystemTimeZoneDidChange`.

**Verificado** con ocho pruebas de límite exacto (04:59, 05:00, 11:59, 12:00, 17:59, 18:00,
23:59) más una de cambio de zona horaria: el mismo instante da `tarde` en Bogotá y `noche`
en Madrid.

**Efecto colateral:** el saludo nocturno pierde el emoji 🌙 que fijaba §4.5. La escena ya
muestra una luna; repetirla en el texto era redundante. El detalle discreto lo aporta ahora
un símbolo en la vista.

---

### D-032 · El score solo puntúa lo que venció y tiene respuesta

**Decisión:** se amplía `ActivityStatus` a nueve estados y el score pasa a ser
**provisional durante el día**.

| Estado | Puntos | Por qué |
|---|---|---|
| completada | 1.0 | |
| parcial | 0.5 | |
| omitida | 0.0 | Fer confirmó que no la hizo |
| programada / proxima | — | Aún puede hacerse. Contarla cero sería castigar el futuro |
| enCurso | — | **Empezar no es cumplir** |
| sinConfirmar | — | Venció sin respuesta. No es un fallo: falta la confirmación |
| reprogramada | — | Mover algo no es fallar (§9.1) |
| cancelada | — | Excluida por especificación |

La ventana de cumplimiento se calcula con `endDate` o, si no lo hay, con la duración
sugerida de la categoría. Sin ventana no se puede saber cuándo preguntar por el resultado.

**FERNÉ no marca nada como cumplido por su cuenta.** El paso de la hora no es una
confirmación: por eso `sinConfirmar` y `omitida` son estados distintos.

**Migración:** el `pendiente` de la versión anterior se lee como `sinConfirmar`
(`ActivityStatus.fromStored`). Los `rawValue` guardados siguen siendo válidos.

**Verificado** con 55 pruebas de dominio, incluidas las nuevas: futuras excluidas, en curso
excluida, parcial = 50 %, sin confirmar separado del incumplimiento, ventana por categoría y
semana sin días futuros en cero.
