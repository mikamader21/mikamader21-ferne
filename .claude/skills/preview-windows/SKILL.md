---
name: preview-windows
description: Ver FERNÉ desde Windows. Úsalo para revisar el diseño con la galería local, para preparar o interpretar un build de CI, o para poner la app en Appetize. Trigger: "ver la app", "cómo se ve", "revisar el diseño", "abrir la galería", "subir a Appetize", "descargar el artifact".
---

# /preview-windows

## Cuándo usarlo
Cuando haya que **mirar** FERNÉ desde Windows: revisar una pantalla, comparar contra la
referencia o preparar un preview interactivo.

## Antes de empezar: di la verdad sobre el entorno
No existe un simulador de iOS nativo en Windows. Nunca afirmes lo contrario. Las tres vías
reales, en orden de coste:

| Vía | Qué da | Qué NO da |
|---|---|---|
| Galería local | Referencias y capturas, al instante | Interacción |
| Appetize | iPhone interactivo en el navegador | Notificaciones, sonidos, haptics, rendimiento |
| iPhone real | Todo | No hay ninguno disponible |

## Procedimiento

### A · Revisar el diseño (rápido)

```bat
Scripts\abrir-galeria.bat
Scripts\abrir-galeria.bat "C:\ruta\FERNE-screenshots"
```

Muestra las referencias aprobadas, las capturas de CI y el estado de cada pantalla.

### B · Obtener capturas nuevas

1. GitHub → **Actions** → última ejecución de **iOS CI**.
2. Descarga el artifact `FERNE-screenshots`.
3. Descomprímelo y pásaselo a la galería.

Para capturar en los tres tamaños de iPhone: **Run workflow** con
`full_screenshot_matrix = true`.

### C · Preview interactivo (Appetize)

1. Descarga el artifact `FERNE-simulator-app`.
2. Sube `FERNE-simulator.zip` a Appetize (**Update**, no un app nuevo).
3. Abre la URL en el navegador.

Detalle completo en `docs/WINDOWS_IOS_PREVIEW.md`.

## Validaciones
- [ ] La galería abre y muestra imágenes reales, no reconstrucciones.
- [ ] Las capturas corresponden a la última ejecución de CI, no a una antigua.
- [ ] Si algo se compara con una referencia, se dice **cuál** y su sha256.
- [ ] Lo revisado en Appetize se reporta como 🟡, nunca como ✅.

## Fallos comunes
- Maquetar la pantalla en HTML "para verla rápido". **Prohibido:** crea una segunda
  implementación que diverge de la real.
- Juzgar la fluidez de una animación en Appetize. Transmite vídeo; no mide rendimiento.
- Dar por buena una pantalla porque "se ve bien" en una captura de un solo tamaño.
- Trabajar con un artifact caducado. Duran 30 días los de app y capturas, 14 el resto.

## Definición de terminado
Galería generada o Appetize actualizado, con la lista de lo revisado, lo que quedó pendiente
y el nivel de confianza de cada observación.
