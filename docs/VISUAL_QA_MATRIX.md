# Matriz de QA visual

Fuente de verdad para el agente `visual-guardian`. Ninguna pantalla se aprueba sin recorrer esta tabla.

**Última actualización:** 6 de agosto de 2026
**Ejecución de CI:** ninguna todavía. Creación del repositorio **autorizada**; pendiente de
`gh auth login` en Windows. Sin capturas no hay comparación posible, y por tanto ninguna
pantalla puede pasar de 🟡.

**Referencias aprobadas: conjunto COMPLETO (3).** Son la autoridad visual de las 40 pantallas,
no solo de las tres que retratan. Cada pantalla nueva se evalúa contra el **sistema derivado**
de ellas: identidad, colores, tipografía, radios, tarjetas, profundidad, iconografía,
iluminación y lenguaje visual.

Análisis: [`DESIGN_REFERENCES.md`](DESIGN_REFERENCES.md) · Diferencias priorizadas:
[`VISUAL_BACKLOG.md`](VISUAL_BACKLOG.md).

---

## Estado global

| Métrica | Valor |
|---|---|
| Pantallas del catálogo | 40 |
| Con esqueleto implementado | 7 |
| Con capturas reales de CI | **0** — el workflow aún no se ha ejecutado |
| Sistema visual de referencia | **completo** — 3 imágenes oficiales |
| Comparadas con referencia | **0** — falta ejecutar el pipeline y generar capturas |
| **Aprobadas** | **0** |

---

## Matriz por pantalla

Leyenda: ✅ hecho · 🟡 parcial · ⬜ pendiente · ⛔ bloqueado · — no aplica todavía

| Pantalla | Implementada | Compila | Screenshot | Comparada con referencia | Accesibilidad | Aprobada | Observaciones |
|---|:---:|:---:|:---:|:---:|:---:|:---:|---|
| 01 · Splash | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Colores aprobados tal cual (D-022). Backlog: #22, #23, #24. |
| 04 · Inicio / Hoy | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Backlog: #6, #10, #11, #12, #15, #17, #18, #19, #21, #25. |
| 28 · Perfil y ajustes | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Muestra el estado real de los sonidos ("Pendiente"). |
| 29 · Personalizar saludo | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Vista previa de las tres franjas, dentro de Perfil. |
| 36 · Mi progreso | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Backlog: #7 ("82 PUNTOS"), #8, #9, #13, #14, #16. |
| 38 · Detalle del score | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Desglose dentro de Progreso. Pantalla propia en Fase 5. |
| 39 · Recomendaciones | 🟡 | ⬜ | ⬜ | ⬜ | 🟡 | ⬜ | Formato de 4 partes implementado. |
| 02, 03, 05–27, 30–35, 37, 40 | ⬜ | — | — | — | — | ⬜ | 33 pantallas pendientes. Ver `PHASE_PLAN.md`. |

**Lectura de la columna "Comparada con referencia":**

Todas están en **⬜**, y por un único motivo: **el pipeline macOS no se ha ejecutado nunca**,
así que no hay capturas que comparar. No falta ninguna referencia ni ninguna decisión.

- Las pantallas 01, 04 y 36 se comparan contra su imagen directa.
- El resto se compara contra el **sistema derivado** de las tres: paleta, tipografía, radios,
  tarjetas, profundidad, iconografía e iluminación.
- Las variantes nocturnas se comparan contra la dirección nocturna **derivada y documentada**
  en `DESIGN_SYSTEM.md` (decisión D-024), no contra una imagen.

---

## Cobertura de capturas

Cada pantalla implementada debe tener capturas en todas las combinaciones aplicables.

### Dimensión 1 · Tamaño de dispositivo

Lo aporta la matriz de simuladores del workflow, no el test.

| Clase | Simulador | Cuándo se captura |
|---|---|---|
| Compacto | `iPhone SE (3rd generation)` | push a `main` o ejecución manual con matriz completa |
| Estándar | `iPhone 16 Pro` | **siempre** |
| Pro Max | `iPhone 16 Pro Max` | push a `main` o ejecución manual con matriz completa |

En ramas de trabajo solo se captura el tamaño estándar: los minutos de runner macOS se facturan x10 en repositorios privados y una matriz de tres en cada push agotaría la cuota.

### Dimensión 2 · Escenario

Se controla por argumento de lanzamiento en el mismo run.

| Escenario | Argumentos | Test |
|---|---|---|
| Mañana | `-FERNEPhase manana` | `testCapturaFranjasHorarias` |
| Tarde | `-FERNEPhase tarde` | `testCapturaFranjasHorarias` |
| Noche | `-FERNEPhase noche` | `testCapturaFranjasHorarias` |
| Estado vacío | `-FERNEFixture vacio` | `testCapturaEstadoVacio` |
| Todo completado | `-FERNEFixture completo` | `testCapturaDiaCompleto` |
| Mixto (completas + pendientes) | `-FERNEFixture mixto` | por defecto |
| Dynamic Type grande | `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityL` | `testCapturaDynamicTypeGrande` |
| Reduce Motion | `-FERNEReduceMotion 1` | `testCapturaReduceMotion` |
| Splash día / noche | `-FERNESkipSplash 0` | `testCapturaSplash` |
| Las 4 pestañas | — | `testCapturaTodasLasPestanas` |

### Cómo se evalúa una pantalla sin imagen propia

37 de las 40 pantallas no tienen referencia individual, y **no la necesitan**. `visual-guardian`
las evalúa contra el sistema derivado:

| Aspecto | De dónde sale |
|---|---|
| Paleta funcional y atmosférica | las tres referencias + `FerneColor` |
| Tipografía y jerarquía | `02-home` y `03-progress` + `DESIGN-TOKENS.md` |
| Tarjetas, radios y profundidad | `02-home` y `03-progress` |
| Escena, luz y partículas | `01-splash` |
| Indicadores, gráficas y estados | `03-progress` |
| Iconografía y navegación | `02-home` |
| Dirección nocturna | derivada, documentada en `DESIGN_SYSTEM.md` (D-024) |

El criterio: **la pantalla debe pertenecer al mismo universo visual**. Si parece de otra app,
se rechaza aunque respete la paleta.

### Limitación honesta sobre Reduce Motion

`-FERNEReduceMotion 1` fuerza el comportamiento **a nivel de app**, no el ajuste del sistema. Sirve para ver cómo se dibuja la escena sin movimiento, pero **no demuestra** que FERNÉ respete `accessibilityReduceMotion` de iOS. Esa conformidad debe verificarse activando el ajuste real en Appetize o en un iPhone, y hasta entonces la casilla de accesibilidad de esa pantalla no pasa de 🟡.

---

## Criterios para marcar "Aprobada"

Las siete, sin excepciones:

1. **Implementada** — todos los estados de la especificación (normal, vacío, cargando, error).
2. **Compila** — build verde en el workflow, sin warnings nuevos evitables.
3. **Screenshot** — capturas en los tres tamaños y en las tres franjas.
4. **Comparada con referencia** — cotejada contra `docs/design-references/` si tiene imagen
   directa, o contra el sistema derivado de las tres si no la tiene.
5. **Accesibilidad** — `/audit-accessibility` sin incumplimientos; VoiceOver y Dynamic Type revisados.
6. **Sin regresión** — el guardián de diseño en verde.
7. **Veredicto de `visual-guardian`** — APRUEBA, nunca "aprueba con reservas".

---

## Cómo actualizar esta matriz

1. Ejecuta el workflow (push, o manualmente con `full_screenshot_matrix = true`).
2. Descarga el artifact `FERNE-screenshots`.
3. Abre `index.html` y revisa cada captura.
4. Compara contra `docs/design-references/` cuando existan.
5. Actualiza la fila de la pantalla y la fecha de esta cabecera.
6. Si algo falla, escribe **qué** falla en Observaciones. Una fila con ⬜ y sin explicación no sirve.

**Nunca** marques ✅ una casilla que no hayas verificado mirando la captura.
