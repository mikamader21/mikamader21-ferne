# Backlog visual

Diferencias entre las tres referencias aprobadas y la implementación actual.

Origen: análisis de `docs/design-references/` frente al esqueleto de la Fase 0
(ver `DESIGN_REFERENCES.md` §4).

**Regla:** ninguna de estas correcciones se da por hecha sin una captura real del pipeline
macOS que lo demuestre. No se corrigen "a ciegas" ni todas de golpe.

## Severidades

| Nivel | Significado |
|---|---|
| **P0** | Identidad incorrecta. La app no se reconoce como FERNÉ. |
| **P1** | Jerarquía, disposición o componente importante. |
| **P2** | Refinamiento visual. |
| **P3** | Microdetalle. |

## Estados

`⬜ pendiente` · `🔵 en curso` · `🟡 aplicado, sin verificar en captura` · `✅ verificado en captura`

---

## Tabla priorizada

| # | Diferencia | Pantalla | Referencia | Implementación actual | Sev. | Acción | Fase | Estado |
|---:|---|---|---|---|:--:|---|:--:|:--:|
| 1 | Botón principal: gradiente oro→magenta | todas | `03-progress` "Organizar mañana" | rosa→coral | **P0** | Ya aplicado en `FerneColor.primaryButtonGradient` | 0.5 | 🟡 |
| 2 | Titulares en magenta de marca `#AE275D` | todas | las tres | `deepPlum` para todo | **P0** | Ya añadido `FerneColor.brandMagenta`; aplicar en vistas | 1–2 | ⬜ |
| 3 | Tipografía Libre Caslon + Hanken Grotesk | todas | `DESIGN-TOKENS.md` | serif del sistema + SF Pro | **P0** | `FerneFont` listo con fallback; faltan los `.ttf` | 2 | 🟡 |
| 4 | Colores atmosféricos en el cielo (cian, lavanda, índigo) | escenas | `01-splash` | degradado solo cálido | **P0** | Ya aplicado en `FerneTheme` mañana/tarde/noche | 0.5 | 🟡 |
| 5 | Tarjetas de vidrio: sin relleno sólido, borde blanco 20 %, blur | todas | `DESIGN-TOKENS.md` §Elevación | relleno `warmWhite` sólido | **P1** | `FerneCard` → `.ultraThinMaterial`, sólido si Reduce Transparency | 7 | ⬜ |
| 6 | "MI DÍA" y "LO QUE SIGUE" lado a lado | 04 | `02-home` | apiladas verticalmente | **P1** | `HStack` de dos tarjetas iguales | 2 | ⬜ |
| 7 | Score como "82 PUNTOS", no porcentaje | 36 | `03-progress` | anillo con `%` | **P1** | Cambiar la presentación; el motor ya da 0–100 | 5 | ⬜ |
| 8 | Tres contadores: Completadas / Pendientes / Reprogramadas | 36 | `03-progress` | no existen | **P1** | Fila de tres con icono circular | 5 | ⬜ |
| 9 | Gráfico de barras L-M-M-J-V-S-D con doble capa | 36 | `03-progress` | no existe | **P1** | Swift Charts, capa clara = objetivo, oscura = logrado | 5 | ⬜ |
| 10 | Chip de cuenta regresiva "Faltan 35 mins" | 04 | `02-home` | no existe | **P1** | Píldora rosa en la tarjeta "Lo que sigue" | 2 | ⬜ |
| 11 | Actividad completada con **título tachado** | 04 | `02-home` "Desayuno" | solo check verde | **P1** | `.strikethrough()` + color atenuado | 2 | ⬜ |
| 12 | Actividad en curso: barra magenta lateral + botón ▶ | 04 | `02-home` "Gym" | no existe | **P1** | Estado "en curso" en `ActivityRow` | 2 | ⬜ |
| 13 | Tarjetas "Lo estás haciendo bien en" / "Podemos mejorar" | 36 | `03-progress` | no existen | **P1** | Con iconos estrella y luna | 5 | ⬜ |
| 14 | Botón "Organizar mañana" | 36 | `03-progress` | no existe | **P1** | Acción al final de Progreso | 5 | ⬜ |
| 15 | Cabecera: hamburguesa izquierda + avatar derecha | 04, 36 | `02-home`, `03-progress` | no existe | **P1** | Barra superior compartida | 2 | ⬜ |
| 16 | Logotipo FERNÉ centrado en la cabecera | 36 | `03-progress` | no existe | **P2** | En la barra superior de Progreso | 5 | ⬜ |
| 17 | Mensaje del día bajo el saludo | 04 | `02-home` "Hoy tienes un día bonito por construir." | no está en Inicio | **P2** | Línea bajo el saludo | 2 | ⬜ |
| 18 | Enlace "Ver todo" junto a "Agenda de hoy" | 04 | `02-home` | sin enlace | **P2** | Navegación a Agenda diaria | 2 | ⬜ |
| 19 | FAB en degradado melocotón-naranja | 04 | `02-home` | degradado rosa-coral | **P2** | Gradiente propio del FAB | 2 | ⬜ |
| 20 | Pestaña activa con píldora rosa de fondo | todas | `02-home`, `03-progress` | estilo por defecto de iOS | **P2** | `TabView` personalizado | 7 | ⬜ |
| 21 | Iconografía: destellos, anillo, varita, persona | todas | `02-home`, `03-progress` | SF Symbols distintos | **P2** | Ajustar símbolos de `MainTabView` | 2 | ⬜ |
| 22 | Splash: logo dentro de tarjeta de vidrio cuadrada | 01 | `01-splash` | logo suelto sobre la escena | **P2** | Contenedor de vidrio con borde tenue | 7 | ⬜ |
| 23 | Splash: círculo luminoso grande abajo a la derecha | 01 | `01-splash` | astro arriba a la derecha | **P2** | Reposicionar el halo | 7 | ⬜ |
| 24 | Malla de color en lugar de degradado vertical | 01 | `01-splash` | 3–4 paradas verticales | **P2** | Malla con `RadialGradient` superpuestos | 7 | ⬜ |
| 25 | Etiquetas en versales con kerning ampliado | 04, 36 | "MI DÍA", "COMPLETADAS" | sin versales | **P3** | `FerneFont.labelCaps` + `.kerning(1.2)` | 2 | ⬜ |

**Total: 25 elementos** (las 21 diferencias del informe, desglosadas cuando una agrupaba
varios cambios independientes).

---

## Reparto por severidad y fase

| Severidad | Total | 🟡 aplicado | ⬜ pendiente |
|---|---:|---:|---:|
| P0 · identidad | 4 | 3 | 1 |
| P1 · jerarquía y componentes | 11 | 0 | 11 |
| P2 · refinamiento | 9 | 0 | 9 |
| P3 · microdetalle | 1 | 0 | 1 |

| Fase | Elementos |
|---|---:|
| 0.5 (ya aplicados) | 2 |
| 1 | 1 |
| 2 | 11 |
| 5 | 6 |
| 7 | 5 |

Los P0 se atacan primero porque afectan a **todas** las pantallas: cambiar el gradiente del
botón o el magenta de titulares después de construir treinta vistas obliga a tocarlas todas.

---

## Cómo se verifica un elemento

1. Se aplica el cambio.
2. Se hace push; el workflow `iOS CI` genera capturas.
3. Se descarga `FERNE-screenshots` y se abre la galería.
4. Se compara la captura con la referencia, lado a lado.
5. Solo entonces el estado pasa a ✅ y se actualiza `VISUAL_QA_MATRIX.md`.

**Un elemento en 🟡 no está terminado.** Significa que el código cambió pero nadie ha visto
el resultado. Cuatro elementos están hoy en 🟡 precisamente por eso: el pipeline no se ha
ejecutado nunca.
