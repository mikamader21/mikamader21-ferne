---
name: verify-design
description: Audita una vista contra la identidad visual aprobada de FERNÉ. Úsalo tras crear o modificar cualquier vista y antes de declarar una pantalla terminada.
---

# /verify-design

## Cuándo usarlo
Después de tocar cualquier archivo de `Features/` o `DesignSystem/`.

## Entradas
Ruta del archivo o nombre de la pantalla. La captura de CI correspondiente, si existe.

## Procedimiento
0. Localiza la referencia aplicable. Las tres imágenes son la autoridad visual de **todas**
   las pantallas:

   | Pantalla | Se compara contra |
   |---|---|
   | 01 Splash | `01-splash-approved.png` (imagen directa) |
   | 04 Inicio | `02-home-approved.png` (imagen directa) |
   | 36 Progreso | `03-progress-approved.png` (imagen directa) |
   | las otras 37 | el **sistema derivado** de las tres |
   | variantes nocturnas | la dirección nocturna derivada de `DESIGN_SYSTEM.md` (D-024) |

   Que una pantalla no tenga imagen propia **no impide evaluarla**. El criterio es si
   pertenece al mismo universo visual: paleta, tipografía, radios, tarjetas, profundidad,
   iconografía, iluminación y esa sensación alegre y cinematográfica. Si parece de otra
   aplicación, se rechaza aunque respete la paleta.

1. Ejecuta `bash Scripts/design-guard.sh` y transcribe la salida.
2. Revisa a mano lo que el script no puede ver:
   - Jerarquía tipográfica: serif en encabezados, SF Pro en cuerpo.
   - Tarjetas: radio 20–24, borde sutil, sombra rosada.
   - Botones: principal con degradado rosa-coral; secundario blanco cálido con borde rosa.
   - Espaciado desde `FerneSpacing`, sin números mágicos.
   - Escena presente y con la intensidad adecuada al contenido.
3. Verifica que existan `#Preview` de mañana y de noche.
4. Abre la captura de CI (`FERNE-screenshots`) y la referencia, y compáralas lado a lado.
   Consulta `docs/VISUAL_BACKLOG.md`: las 25 diferencias conocidas ya están listadas y
   priorizadas. No las vuelvas a descubrir; comprueba si la que tocaba está resuelta y
   actualiza su estado.
5. Actualiza la fila correspondiente de `docs/VISUAL_QA_MATRIX.md`.

## Validaciones
- [ ] Sin negro puro.
- [ ] Sin hex fuera de `FerneColor`/`FerneTheme`.
- [ ] Rojo solo en error técnico o pago vencido.
- [ ] Colores atmosféricos (cian, lavanda, índigo) solo en escenas, nunca en UI.
- [ ] Sin fondo plano.
- [ ] Sol de día, luna de noche.

## Fallos comunes
- `Color.gray`, `Color.secondary` o `.white` sueltos donde debería ir un token.
- Fondo `Color(.systemBackground)`: rompe la identidad por completo.
- Sombras apiladas que hunden el rendimiento en listas.

## Definición de terminado
Veredicto **APRUEBA**, **RECHAZA** o **NO VERIFICABLE**, con archivo y línea de cada
incumplimiento, y la matriz actualizada. No existe "aprueba con reservas".
