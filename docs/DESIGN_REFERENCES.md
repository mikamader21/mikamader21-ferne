# Análisis de las referencias visuales

Fecha: 6 de agosto de 2026 · **Conjunto completo: 3 referencias oficiales**

Las tres imágenes son la **autoridad visual global** de FERNÉ. No existe una cuarta.

Este documento comparaba las referencias con `MASTER_SPEC.md` y exponía las contradicciones
para que las decidieras. **Ya están decididas** (6 de agosto de 2026):

| Asunto | Decisión | Registro |
|---|---|---|
| Colores fríos del Splash | **Aprobados tal cual.** Se crea el grupo de colores atmosféricos | D-022 |
| Escena nocturna sin referencia | **Se deriva** del mismo sistema, no se espera imagen | D-024 |
| Libre Caslon Text + Hanken Grotesk | **Aprobadas.** D-003 queda superada | D-023 |
| Gradiente de botón oro→magenta | Aplicado | backlog #1 |
| Token `primary #AE275D` | Añadido como `brandMagenta` | backlog #2 |
| Tarjetas de vidrio | Aceptado, se aplica en Fase 7 | backlog #5 |

Las 25 diferencias detectadas viven en [`VISUAL_BACKLOG.md`](VISUAL_BACKLOG.md), priorizadas
de P0 a P3.

---

## 1. Inventario

| Archivo | Dimensiones | Peso | Contenido |
|---|---|---|---|
| `01-splash-approved.png` | 706 × 1600 | 757 KB | Splash: logo FERNÉ sobre malla de color |
| `02-home-approved.png` | 635 × 1600 | 550 KB | Inicio con cielo fotográfico y amanecer |
| `03-progress-approved.png` | 403 × 1600 | 311 KB | Progreso con score, contadores y barras |
| `DESIGN-TOKENS.md` | — | 6,8 KB | Sistema de diseño "Cinematic Radiance" |

Conjunto completo. Las tres imágenes bastan: son la autoridad visual de las 40 pantallas.

Cada carpeta original incluye además un `code.html` que sirvió para leer valores exactos de
gradientes. **No se usa como código**: FERNÉ es SwiftUI nativo.

---

## 2. Colores del Splash · RESUELTO (D-022)

Muestreo real de píxeles de `01-splash-approved.png`:

| Zona | Color | Tono | Grupo |
|---|---|---|---|
| Esquina sup. izquierda | `#FF88A8` | rosa 343° | atmosférico · `dawnPink` |
| Esquina sup. derecha | `#69E6FC` | cian 188° | atmosférico · `skyCyan` |
| Borde derecho medio | `#C6AFD3` | violeta 278° | atmosférico · `lavender` |
| Esquina inf. izquierda | `#FFB68C` | naranja 21° | atmosférico · `dawnPeach` |
| Esquina inf. derecha | `#B0A6EA` | azul 248° | atmosférico · `softIndigo` |

**Decisión: la referencia se conserva exactamente como está.** Los colores fríos no
contradicen la identidad; son **colores atmosféricos**.

### La paleta tiene ahora dos grupos

| Grupo | Colores | Dónde pueden aparecer |
|---|---|---|
| **Funcionales** | rosas, coral, dorado, ciruela, blanco cálido, verde de completado, ámbar de atención | Botones, texto, tarjetas, estados, navegación, formularios |
| **Atmosféricos** | cian cielo, lavanda, índigo suave, rosa de amanecer, melocotón, ciruela nocturno | Splash, cielos, transiciones, reflejos, amanecer, noche, fondos cinematográficos, partículas, halos |

Los atmosféricos **nunca** son dominantes en botones, formularios ni navegación. Está
verificado por `Scripts/design-guard.sh`, que falla si un `FerneColor.skyCyan` (o similar)
aparece fuera de `DesignSystem/Scenes/` o `DesignSystem/Theme/`. Se probó introduciendo la
violación a propósito: el guardián la detecta.

**Regla general:** cuando la referencia visual y la lista inicial de §4.2 difieran de forma
demostrable, **manda la referencia**.

## 3. `DESIGN-TOKENS.md` aporta valores que la especificación no tenía

El documento de diseño ("Cinematic Radiance") es más detallado que §4 en varios puntos. No
contradice la especificación, la extiende.

### 3.1 Tipografía: nombres concretos

| | `MASTER_SPEC.md` §4.3 | `DESIGN-TOKENS.md` | Fase 0 implementó |
|---|---|---|---|
| Titulares | "serif elegante con licencia apta **o tipografía del sistema equivalente**" | **Libre Caslon Text** | serif del sistema |
| Cuerpo | "SF Pro / tipografía del sistema" | **Hanken Grotesk** | SF Pro |

Ambas fuentes son de **Google Fonts con licencia SIL Open Font License 1.1**, que permite
incrustarlas en una app comercial. La decisión D-003 (usar la serif del sistema) se tomó
por prudencia ante una licencia desconocida; ahora se conoce.

**Decisión D-023: ambas aprobadas.** Libre Caslon Text para logotipo, saludos y titulares
editoriales; Hanken Grotesk para textos de marca, subtítulos y contenido general; SF Pro para
controles nativos pequeños y accesibilidad.

`FerneFont` ya está implementado con **fallback automático**: si un `.ttf` no está en el
bundle, cae a la fuente del sistema con el mismo diseño. Los archivos aún no se han
descargado; ver `FERNE/Resources/Fonts/README.md` y `Scripts/verify-fonts.sh`.

### 3.2 Color primario: hay dos magentas

`DESIGN-TOKENS.md` distingue lo que §4.2 unificaba:

| Token | Valor | Uso |
|---|---|---|
| `primary` | `#AE275D` | Texto de marca, titulares magenta, trazo del anillo |
| `primary-container` | `#F45F92` | = `fernePink` de §4.2. Relleno de acciones |
| `on-surface` | `#1D1B1B` | Texto de cuerpo (§4.2 usaba `deepPlum` para todo) |
| `outline` | `#8A7076` | ≈ `roseGray` |

En las tres referencias, los titulares grandes ("Buenos días, Fer", "82", "FERNÉ") usan el
magenta profundo `#AE275D`, no el rosa de acción. **Es un token que falta en `FerneColor`.**

### 3.3 Botón principal: el gradiente va al revés

| Fuente | Gradiente |
|---|---|
| `MASTER_SPEC.md` §4.4 | "degradado rosa-coral" |
| `DESIGN-TOKENS.md` | "Morning Gold **to** Coral Pink" |
| `03-progress-approved.png` ("Organizar mañana") | oro → magenta, de izquierda a derecha |
| Fase 0 implementó | `fernePink` → `peachCoral` |

La referencia manda oro→magenta. Es un cambio pequeño y sin conflicto de paleta: **se puede
aplicar sin aprobación adicional**, y queda propuesto para la Fase 7.

### 3.4 Profundidad: glassmorphism, no tarjeta sólida

`DESIGN-TOKENS.md` es explícito: *"Glass Cards: containers must have a 1px solid border
`rgba(255,255,255,0.2)` and a background blur. **No solid fills.**"*

La Fase 0 implementó `FerneCard` con relleno sólido `warmWhite` y solo translúcido de noche.
Las referencias 1 y 3 muestran tarjetas claramente translúcidas, con el degradado del fondo
atravesándolas.

**Ajuste propuesto (Fase 7):** `FerneCard` pasa a `.ultraThinMaterial` con borde blanco al
20 %, con caída a relleno sólido cuando `Reduce Transparency` está activo. Compatible con
§4.4 ("blanco cálido/translúcido").

### 3.5 Radios: coexisten dos escalas

`DESIGN-TOKENS.md` usa 8 px para componentes estándar y 24 px (`rounded-xl`) para
"Feature Containers". §4.4 pide 20–24 pt para tarjetas. La Fase 0 usa 22.

No hay conflicto: las tarjetas de contenido son Feature Containers (22–24), y los controles
pequeños pueden bajar a 8–16. Ya existe `FerneRadius.control = 16`.

---

## 4. Diferencias entre las referencias y el esqueleto de la Fase 0

Lista honesta de lo que **no** coincide todavía. Ninguna es un error: la Fase 0 construyó
arquitectura, no pantallas terminadas.

### Inicio (`02-home-approved.png`)

| Elemento de la referencia | Estado en Fase 0 |
|---|---|
| Menú hamburguesa arriba a la izquierda | no existe |
| Avatar circular arriba a la derecha | no existe |
| Cielo **fotográfico** con sol sobre un paisaje | escena procedural SwiftUI |
| "Hoy tienes un día bonito por construir." bajo el saludo | mensaje del día no está en Inicio |
| "MI DÍA" y "LO QUE SIGUE" como dos tarjetas **lado a lado** | apiladas |
| Chip "Faltan 35 mins" (cuenta regresiva) | no implementado |
| "Agenda de hoy" con enlace "Ver todo" | sin enlace |
| Actividad completada con **título tachado** | solo check verde |
| Actividad en curso con barra magenta lateral y botón ▶ | no implementado |
| FAB en degradado **melocotón-naranja** | degradado rosa-coral |
| Iconos de pestaña: destellos, anillo, varita, persona | SF Symbols distintos |
| Pestaña activa con **píldora rosa de fondo** | estilo por defecto de iOS |

### Progreso (`03-progress-approved.png`)

| Elemento de la referencia | Estado en Fase 0 |
|---|---|
| Logo **FERNÉ** centrado en la cabecera | no existe |
| "Así va tu semana, Fer" | "Mi progreso" |
| Score como **"82 PUNTOS"**, no porcentaje | anillo con `%` |
| Tres contadores: Completadas / Pendientes / Reprogramadas | no implementados |
| Gráfico de barras L-M-M-J-V-S-D con capa clara y capa oscura | no implementado (Fase 5) |
| "LO ESTÁS HACIENDO MUY BIEN EN:" con icono estrella | no implementado |
| "PODEMOS MEJORAR:" con icono luna | no implementado |
| Botón "Organizar mañana" oro→magenta | no implementado |
| Desglose de los 4 componentes con sus pesos | **sí implementado** (no aparece en la referencia) |

> **Nota sobre "82 PUNTOS":** la referencia presenta el score como puntos, no como porcentaje.
> El motor de §9.2 calcula un valor 0–100 ponderado, así que numéricamente encaja. Es una
> decisión de *presentación*: "82 PUNTOS" en lugar de "82 %". Se adopta en la Fase 5 salvo
> que indiques lo contrario.

### Splash (`01-splash-approved.png`)

| Elemento de la referencia | Estado en Fase 0 |
|---|---|
| Malla de color multicolor a pantalla completa | degradado vertical de 3–4 paradas |
| Tarjeta de vidrio cuadrada con el logo dentro | logo suelto sobre la escena |
| Círculo luminoso grande, descentrado abajo a la derecha | astro arriba a la derecha |
| Partículas dispersas tipo estrella | sí implementado |
| Serif magenta con acento en la É | sí, serif del sistema |
| **Cian e índigo** | conflicto abierto, ver §2 |

---

## 5. Qué queda pendiente

| Asunto | Estado |
|---|---|
| Referencias 01, 02, 03 | **COMPLETO** — son el conjunto oficial |
| Dirección visual general | **APROBADA** — las tres imágenes la definen |
| Escena nocturna | **DERIVADA Y DOCUMENTADA** (D-024) |
| Colores del Splash | **APROBADOS** (D-022) |
| Tipografía | **APROBADA** (D-023) · archivos `.ttf` pendientes de descarga |
| 25 diferencias visuales | En backlog priorizado, 4 ya aplicadas sin verificar |
| **Comparación real contra las referencias** | **PENDIENTE** — solo hasta ejecutar el pipeline y generar capturas |

Lo único que impide aprobar pantallas es que **el pipeline macOS no se ha ejecutado todavía**.
No falta ninguna referencia ni ninguna decisión.
