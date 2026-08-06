# Modelos de datos

Estado: **Fase 0 entrega los `struct` puros del dominio. Los `@Model` de SwiftData son trabajo de la Fase 1.**

## Entidad base: `Activity` (§7.1)

Implementada como `ActivitySnapshot` en `Domain/Entities/ActivitySnapshot.swift`.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | `UUID` | Base del identificador de notificación: `"\(id)#\(index)"`. |
| `title` | `String` | Dato personal. **Nunca en logs.** |
| `notes` | `String?` | Dato personal. |
| `category` | `ActivityCategory` | 12 casos. `rawValue` es contrato. |
| `startDate` | `Date` | Determina el día natural de la actividad. |
| `endDate` | `Date?` | |
| `allDay` | `Bool` | |
| `recurrenceRule` | `RecurrenceRule?` | Se resuelve con `Calendar` explícito. |
| `reminderOffsets` | `[TimeInterval]` | Segundos **antes** del inicio. Una notificación por elemento. |
| `soundID` | `String?` | `nil` ⇒ sonido global. Ver `SoundLibrary`. |
| `priority` | `Priority` | `esencial` habilita alarma prominente. |
| `requiresConfirmation` | `Bool` | Repetir hasta confirmar. |
| `status` | `ActivityStatus` | 6 casos. Gobierna el score. |
| `completedAt` | `Date?` | |
| `rescheduledFrom` | `Date?` | Fecha original tras reprogramar. |
| `createdAt` / `updatedAt` | `Date` | |

### Categorías (12)

`despertar` · `comida` · `gym` · `trabajo` · `live` · `lectura` · `pago` · `rutina` · `evento` · `nota` · `dormir` · `personal`

Marcadores derivados: `isKeySchedule` (despertar, comida, dormir) e `isWeeklyCommitment` (gym, live, lectura), usados por el score semanal.

### Estados (6)

`programada` · `completada` · `pendiente` · `reprogramada` · `omitida` · `cancelada`

`isEvaluable` decide la entrada al denominador del score. Es la propiedad más delicada del dominio: cambiarla altera todo el sistema de progreso.

## Entidades pendientes (Fase 1) — §7.2

`Routine` · `RoutineStep` · `Payment` · `MealSchedule` · `GymSession` · `LiveSession` · `ReadingSession` · `DailyReflection` · `DailyScoreSnapshot` · `WeeklyScoreSnapshot` · `NotificationPreference` · `SoundPreference` · `UserPreferences` · `AIIntegrationConfig`.

**`AIIntegrationConfig` no guarda claves.** Solo el estado de conexión y los permisos granulares. Las claves viven en Keychain.

## Migraciones (§7.3)

- El esquema se versiona desde el primer `@Model` (`VersionedSchema` + `SchemaMigrationPlan`).
- Toda modificación de un modelo llega con su `MigrationStage` escrita **antes** del cambio.
- Los `rawValue` de los enums persistidos son contrato: renombrarlos rompe los datos ya guardados en el dispositivo.
- **Prohibido** borrar datos para resolver una migración fallida.
- Cada migración necesita su prueba: datos del esquema anterior → migrar → verificar que sobreviven.

## Regla de proyección

```
@Model Activity  ──toSnapshot()──▶  ActivitySnapshot  ──▶  ScoreEngine
```

Una sola dirección. El dominio nunca conoce SwiftData; así el score se prueba sin contenedor.
