# Sonidos de FERNÉ

Los seis sonidos de producto definidos en `docs/MASTER_SPEC.md` §8.3:

| ID interno | Nombre de producto | Archivo esperado | Uso sugerido |
|---|---|---|---|
| `amanecer` | Amanecer | `amanecer.caf` | Despertar |
| `campanita` | Campanita | `campanita.caf` | Recordatorios |
| `destello`  | Destello  | `destello.caf`  | Confirmaciones |
| `flor`      | Flor      | `flor.caf`      | Comidas |
| `luna`      | Luna      | `luna.caf`      | Dormir |
| `sueno`     | Sueño     | `sueno.caf`     | Rutina nocturna |

## Requisitos técnicos (iOS)

- Formato: `.caf` (recomendado), `.aiff` o `.wav`. Codificación **Linear PCM** o IMA4.
- Duración máxima efectiva para `UNNotificationSound`: **30 segundos**. Por encima, iOS usa el sonido por defecto.
- Deben estar en el bundle de la app (no en Assets.xcassets) y referenciarse por nombre de archivo.
- AlarmKit usa su propia configuración de sonido; ver `docs/NOTIFICATIONS.md`.

## Licencia — BLOQUEO ABIERTO

**Los archivos de audio todavía no existen.** No se han incluido placeholders para no simular una entrega.
Deben ser originales o con licencia explícita de distribución comercial en App Store.
Hasta entonces, `SoundLibrary` expone los seis sonidos con `isAvailable == false` y la app cae al sonido del sistema.

Conversión recomendada una vez existan los originales:

```bash
afconvert -f caff -d LEI16@44100 -c 1 amanecer.wav amanecer.caf
```
