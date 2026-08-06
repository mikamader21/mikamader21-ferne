# Referencias visuales aprobadas

**Estado: conjunto COMPLETO.** Las tres imágenes son las únicas referencias oficiales y son
suficientes. Verificadas el 6 de agosto de 2026.

> No existe ni existió una cuarta imagen. No la esperes.

## Autoridad

Estas tres imágenes son la **autoridad visual global de FERNÉ**, no solo de las pantallas que
retratan:

| Referencia | Define |
|---|---|
| `01-splash-approved.png` | Identidad cinematográfica, gradientes, luz, partículas, profundidad, movimiento |
| `02-home-approved.png` | Organización visual, tarjetas, jerarquía, saludo, escena, agenda, iconografía |
| `03-progress-approved.png` | Indicadores, gráficas, círculos, score, estados, recomendaciones |

Las otras 37 pantallas **se derivan** de este sistema. No hace falta una imagen aprobada por
pantalla para implementarla: `visual-guardian` evalúa cada pantalla nueva contra el sistema
derivado de estas tres.

## Qué hay

| Archivo canónico | Origen entregado | Papel | sha256 (primeros 32) |
|---|---|---|---|
| `01-splash-approved.png` | `2/screen.png` | Splash cinematográfico · pantalla 01 | `858f064c2f4b7b2c0487f08281eef501` |
| `02-home-approved.png` | `1/screen.png` | Inicio: saludo, sol, agenda y tarjetas · pantalla 04 | `fc082353450890be1f6619ea0f6e6999` |
| `03-progress-approved.png` | `3/screen.png` | Score, gráficas e indicadores · pantalla 36 | `51ceb65b4ec5dc363258b75842b429c9` |
| `DESIGN-TOKENS.md` | `1/DESIGN.md` | Sistema de diseño completo: colores, tipografía, formas, profundidad | `b384ccee1ef9364e5d8ae80db7a3ac24` |

Las carpetas `1/`, `2/` y `3/` **se conservan intactas** tal como las entregaste, con su
`screen.png`, su `code.html` y su `DESIGN.md`. Los archivos con nombre canónico son copias
byte a byte (mismos sha256), creados para que la matriz de QA y la galería puedan
referenciarlos de forma estable.

Los tres `DESIGN.md` son idénticos entre sí (`md5 efb88354e08d56a09f932993463c3ea1`).

## Cómo se dedujo el mapeo

No venía indicado. Se abrió cada imagen y se identificó por su contenido:

- `2/screen.png` — logo **FERNÉ** centrado sobre malla de color con la frase "Tu día, a tu ritmo." → **Splash**.
- `1/screen.png` — "Buenos días, Fer ✨", anillo "MI DÍA 78%", "LO QUE SIGUE", "Agenda de hoy" → **Inicio**.
- `3/screen.png` — "Así va tu semana, Fer", "82 PUNTOS", gráfico L-M-M-J-V-S-D → **Progreso**.

Si el mapeo es incorrecto, dímelo antes de que se construya ninguna pantalla sobre él.

## La escena nocturna se deriva, no se espera

Ninguna de las tres referencias es nocturna. La variante de noche **no queda bloqueada por
ello**: se deriva profesionalmente del mismo universo visual (decisión D-024), conservando
rosados, lavanda e índigo y bajando la luminosidad hacia el ciruela.

Implementada en `FerneTheme.noche`. Prohibido: negro puro, azul corporativo, cielo frío
genérico, estética espacial, neón, perder los rosados o eliminar las tarjetas cálidas.

## Estas imágenes NO se copian al código

`Scripts/design-guard.sh` y la política del proyecto lo impiden a propósito:

- Son **referencia de comparación**, no assets de la app.
- FERNÉ dibuja sus escenas con SwiftUI (`SkyScene`), de forma procedural. Meter un PNG de
  1600 px como fondo rompería Dynamic Type, el rendimiento y el redimensionado entre iPhone
  compacto y Pro Max.

### Cómo se convertirán en assets, si se decide hacerlo

Solo si en la Fase 7 se demuestra que la escena procedural no alcanza la calidad de la
referencia:

1. Recortar únicamente el elemento necesario (por ejemplo, la textura de nubes), nunca la
   pantalla completa.
2. Exportar a **HEIC** o **PNG-8** optimizado, a 2x y 3x, con el ancho real de uso.
3. Colocar en `FERNE/Resources/Assets.xcassets/Scenes/` con *Preserve Vector Data* desactivado.
4. Confirmar la licencia de cualquier fotografía incluida (la referencia de Inicio contiene
   un cielo fotográfico y un avatar; **ninguno de los dos puede entrar al binario sin licencia**).
5. Registrar la decisión en `docs/DECISIONS.md` con el peso añadido al bundle.

Ver el análisis completo en [`../DESIGN_REFERENCES.md`](../DESIGN_REFERENCES.md).
