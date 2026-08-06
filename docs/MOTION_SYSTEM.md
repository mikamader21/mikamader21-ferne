# Sistema de movimiento

Todas las duraciones viven en `FERNE/DesignSystem/Tokens/FerneMotion.swift`. Ninguna vista declara la suya.

## Presupuesto (MASTER_SPEC §4.6)

| Uso | Constante | Duración | Rango permitido |
|---|---|---|---|
| Micro-transición | `quick` | 0.20 s | 0.20–0.45 |
| Transición estándar | `standard` | 0.32 s | 0.20–0.45 |
| Transición expresiva | `expressive` | 0.45 s | 0.20–0.45 |
| Escena de splash | `splash` | 2.6 s | 2.0–3.0 |

Los rangos están codificados como `uiRange` y `sceneRange` y **hay una prueba que falla si una duración se sale** (`ThemeTests.testMotionDurationsStayInsideTheApprovedRanges`).

## Ambiente

| Elemento | Ciclo | Notas |
|---|---|---|
| Sol / luna | 24 s | Deriva vertical de ±10 pt. Movimiento lento, casi imperceptible. |
| Nubes | 38 s | Deriva horizontal de ±18 pt, con desenfoque. |
| Partículas / estrellas | 4.5 s + desfase | Densidad **14** partículas. Máximo aceptado: 20. |
| Check al completar | `elasticCheck` | `spring(response: 0.38, dampingFraction: 0.58)`. |
| Progreso | `progress` | `easeInOut(0.45)`. Barras y anillos siempre animan su cambio. |

Las posiciones de las estrellas son **deterministas**, no aleatorias: las capturas de QA visual deben ser reproducibles entre ejecuciones.

## Reduce Motion

Regla que no se negocia: **reducir movimiento no significa quitar la escena.**

Con `accessibilityReduceMotion` activo:

- Cielo, astro, halo, nubes y estrellas **siguen dibujándose**.
- Se detiene toda animación de repetición.
- El Splash muestra logo y frase de inmediato y dura ~1 s.
- Las transiciones de escala pasan a `.opacity`.

`FerneMotion.respectingReduceMotion(_:reduceMotion:)` devuelve `nil` para desactivar una animación de un modo verificable.

## Reduce Transparency

Las superficies translúcidas de la noche (`FerneCard` sobre cielo ciruela) pasan a `warmWhite` sólido.

## Haptics

Permitidos: completar una actividad, confirmar, FAB, alarma, celebración semanal.
Prohibidos: scroll, aparición de vistas, cada pulsación de una lista.
Configurable por la usuaria (`ferne.haptics.enabled`); `Haptics` respeta la preferencia en todos sus métodos.

## Rendimiento

Objetivo 60 fps. Cuidado con:

- `blur` dentro de celdas que hacen scroll.
- Sombras apiladas sobre listas largas.
- `repeatForever` en elementos que se recrean en cada render.

## Lottie

Solo si aporta algo que SwiftUI no logra, únicamente en Splash o celebraciones, y solo con assets propios o con licencia. **Aún no se ha añadido**: la escena actual es SwiftUI nativa y cumple. Requiere aprobación explícita antes de incorporarse.
