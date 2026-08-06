# Sistema de diseño

## Autoridad visual

Este documento desarrolla `MASTER_SPEC.md` §4. Tiene dos fuentes por encima:

1. **`MASTER_SPEC.md` §4** — la especificación aprobada. Manda en caso de conflicto.
2. **`docs/design-references/`** — las tres imágenes aprobadas. **Conjunto completo.**

| Referencia | Define, para TODA la app |
|---|---|
| `01-splash-approved.png` | Identidad cinematográfica, gradientes, luz, partículas, profundidad, movimiento |
| `02-home-approved.png` | Organización visual, tarjetas, jerarquía, saludo, escena, agenda, iconografía |
| `03-progress-approved.png` | Indicadores, gráficas, círculos, score, estados, recomendaciones |
| `DESIGN-TOKENS.md` | Sistema "Cinematic Radiance": tokens, tipografía, formas, profundidad |

**Estas tres imágenes son la autoridad visual de las 40 pantallas**, no solo de las que
retratan. Las otras 37 se derivan de ellas manteniendo identidad, colores, tipografía, radios,
tarjetas, profundidad, iconografía, iluminación, lenguaje visual y la misma sensación alegre,
viva y cinematográfica.

No hace falta una imagen aprobada por pantalla antes de implementarla. `visual-guardian`
evalúa cada pantalla nueva contra el sistema derivado de estas tres.

Análisis completo en [`DESIGN_REFERENCES.md`](DESIGN_REFERENCES.md); diferencias priorizadas
en [`VISUAL_BACKLOG.md`](VISUAL_BACKLOG.md).

### Decisiones aplicadas desde las referencias

| # | Ajuste | Estado |
|---|---|---|
| 1 | Grupo de **colores atmosféricos** (D-022) | ✅ aplicado en `FerneColor` y `FerneTheme` |
| 2 | Token `brandMagenta #AE275D` para titulares | ✅ añadido · falta usarlo en las vistas |
| 3 | Gradiente del botón principal oro → magenta | ✅ aplicado |
| 4 | Escena nocturna derivada (D-024) | ✅ aplicada en `FerneTheme.noche` |
| 5 | Libre Caslon Text + Hanken Grotesk (D-023) | ✅ aprobadas · `FerneFont` con fallback · `.ttf` pendientes |
| 6 | `FerneCard` con glassmorphism | ⬜ Fase 7 |

## Paleta (MASTER_SPEC §4.2)

| Token | Hex | Uso | Constante |
|---|---|---|---|
| ivoryRose | `#FFF8F7` | Fondo base | `FerneColor.ivoryRose` |
| warmWhite | `#FFFCFB` | Tarjetas | `FerneColor.warmWhite` |
| cloudPink | `#FADCE6` | Superficies suaves | `FerneColor.cloudPink` |
| softPink | `#F7A3BE` | Acentos secundarios | `FerneColor.softPink` |
| fernePink | `#F45F92` | Acción principal | `FerneColor.fernePink` |
| peachCoral | `#F7A39A` | Amanecer y gradientes | `FerneColor.peachCoral` |
| sunGold | `#F6C978` | Sol y destacados | `FerneColor.sunGold` |
| deepPlum | `#3C102F` | Títulos | `FerneColor.deepPlum` |
| secondaryPlum | `#672846` | Texto e iconos | `FerneColor.secondaryPlum` |
| roseGray | `#876D79` | Texto secundario | `FerneColor.roseGray` |
| successSoft | `#9FD4B4` | Completado / pagado | `FerneColor.successSoft` |
| attentionAmber | `#F4B86A` | Atención no crítica | `FerneColor.attentionAmber` |

**Rojo (`criticalRed #D64545`):** reservado a errores técnicos y pagos vencidos. **Nunca** para juzgar hábitos ni el score.

**Magenta de marca (`brandMagenta #AE275D`):** titulares editoriales y trazos de progreso. Es
el `primary` de `DESIGN-TOKENS.md`, distinto de `fernePink` (relleno de acción). En las tres
referencias, "Buenos días, Fer", "82" y "FERNÉ" usan este.

## Colores atmosféricos (decisión D-022)

Muestreados de `01-splash-approved.png`. **Uso exclusivo en escenas.**

| Token | Hex | Papel |
|---|---|---|
| `skyCyan` | `#69E6FC` | Cian cielo. Zona alta del amanecer. |
| `softIndigo` | `#B0A6EA` | Índigo suave. Profundidad nocturna. |
| `lavender` | `#C6AFD3` | Lavanda. Transición día-noche. |
| `dawnPink` | `#FF88A8` | Rosa de amanecer. |
| `dawnPeach` | `#FFB68C` | Melocotón de amanecer. |
| `nightPlum` | `#8A5E86` | Ciruela nocturno. |
| `luminousWhite` | `#FDF3F6` | Blanco nacarado. Luna y destellos. |

**Dónde pueden aparecer:** Splash, cielos, transiciones, reflejos, amanecer, noche, fondos
cinematográficos, partículas y halos.

**Dónde no:** botones, formularios, navegación, texto y estados. Nunca como color dominante
de interfaz.

`Scripts/design-guard.sh` lo verifica: falla si un color atmosférico aparece fuera de
`DesignSystem/Scenes/` o `DesignSystem/Theme/`. Probado con una violación real.

Un único punto de entrada: `FERNE/DesignSystem/Tokens/FerneColor.swift`. SwiftLint y `design-guard.sh` rechazan cualquier hex fuera de ahí.

## Temas por franja horaria (§4.5)

| Franja | Horario | Cielo | Astro | Estrellas | Saludo |
|---|---|---|---|---|---|
| Mañana | 05:00–11:59 | dawnPink → cloudPink → **skyCyan 18 %** → peachCoral → ivoryRose | Sol suave + halo coral | no | "Buenos días, Fer ✨" |
| Tarde | 12:00–18:59 | **skyCyan 12 %** → dawnPeach → peachCoral → cloudPink → ivoryRose | Sol alto + destellos dorados | no | "Buenas tardes, Fer" |
| Noche | 19:00–04:59 | deepPlum → secondaryPlum → **softIndigo 45 %** → nightPlum → **lavender 70 %** → softPink | Luna cálida + **halo dorado** | sí (0.9) | "Buenas noches, Fer 🌙" |

### La noche se deriva, no se copia (D-024)

No existe referencia nocturna. La variante de noche se construye del **mismo universo visual**
de las tres referencias: conserva rosados, lavanda e índigo, y baja la luminosidad hacia el
ciruela.

- **Luna cálida**, con halo dorado. La luna de FERNÉ no es fría.
- **Nubes rosadas oscuras**, no grises.
- **Partículas blancas y doradas**, alternadas.
- **El rosado nunca desaparece** del degradado.

**Prohibido:** fondo negro puro, azul corporativo, cielo frío genérico, estética espacial
oscura, neón, perder los tonos rosados, eliminar las tarjetas cálidas.

La noche debe sentirse como el mismo universo, no como otra aplicación.

**El color más oscuro que existe en FERNÉ es `deepPlum #3C102F`.** Negro puro está prohibido y verificado por script.

La franja la decide `DayPhase` (dominio puro, con pruebas de límites). El aspecto lo decide `FerneTheme`. Las vistas no calculan la hora.

## Tipografía (§4.3)

| Rol | Constante | Fuente |
|---|---|---|
| Logotipo y escena | `FerneFont.display` | Libre Caslon Bold 40 |
| Saludo | `FerneFont.greeting` | Libre Caslon Bold 30 |
| Sección | `FerneFont.sectionTitle` | Libre Caslon Regular 22 |
| Tarjeta | `FerneFont.cardTitle` | Hanken SemiBold 17 |
| Cuerpo | `FerneFont.body` | Hanken Regular 17 |
| Secundario | `FerneFont.secondary` | Hanken Regular 15 |
| Metadatos | `FerneFont.meta` | Hanken Medium 13 |
| Etiqueta en versales | `FerneFont.labelCaps` | Hanken Bold 12 + kerning |
| Score | `FerneFont.scoreNumber` | Libre Caslon Bold 44 |

Se usa la serif del **sistema** (`design: .serif`), no una fuente de terceros: evita un problema de licencia de distribución y funciona con Dynamic Type sin trabajo extra. Si más adelante se aprueba una serif con licencia comercial, solo cambia este archivo.

Todo escala con Dynamic Type. Texto esencial nunca por debajo de 14 pt equivalentes.

## Componentes base

| Componente | Archivo | Notas |
|---|---|---|
| `FerneScreen` | `Components/FerneScreen.swift` | Contenedor con `SkyScene` incorporado. **Toda pantalla lo usa.** |
| `FerneCard` | `Components/FerneCard.swift` | Radio 22, borde sutil, sombra rosada. Translúcida de noche; sólida si Reduce Transparency. |
| `FernePrimaryButtonStyle` | `Components/FerneButtons.swift` | Degradado rosa-coral, texto blanco, altura ≥ 44. |
| `FerneSecondaryButtonStyle` | `Components/FerneButtons.swift` | Blanco cálido con borde rosa. |
| `FerneFloatingActionButton` | `Components/FerneButtons.swift` | Círculo rosa 60 pt, `+`, haptic suave. |
| `FerneProgressRing` | `Components/FerneProgress.swift` | Anillo animado con gradiente angular. |
| `FerneProgressBar` | `Components/FerneProgress.swift` | Barra animada. |
| `FerneCheckmark` | `Components/FerneProgress.swift` | Check elástico. Dibujo 28 pt, área táctil 44 pt. |
| `FerneEmptyState` | `Components/FerneScreen.swift` | Estado vacío amable sobre la escena. |
| `SkyScene` | `Scenes/SkyScene.swift` | Cielo + astro + halo + nubes + estrellas + partículas. |

**Regla:** si un elemento aparece dos veces, se convierte en componente antes de construir la segunda pantalla.

## Espaciado y forma

`FerneSpacing`: 4 / 8 / 12 / 16 / 24 / 32 / 48. Margen de pantalla: 20.
`FerneRadius`: tarjeta 22 (rango aprobado 20–24), control 16, pill.
`FerneSize`: área táctil mínima **44**, FAB 60, icono de categoría 40.

Prohibido el número mágico en una vista.
