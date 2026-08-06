# Notificaciones, alarmas y sonidos

Estado: **Fase 0 entrega `SoundLibrary` y la política. La implementación completa es la Fase 4.**

## Principio rector (§8.1)

**La interfaz no puede prometer lo que iOS no garantiza.**

Antes de mostrar "te avisaré a las 7:00", hay que consultar `UNUserNotificationCenter.notificationSettings()`. Si el permiso está denegado o el sonido desactivado, la UI muestra el estado real y ofrece un enlace a Ajustes de iOS. Nunca se afirma una entrega que el sistema puede no hacer.

## Implementación (§8.2)

| Elemento | Decisión |
|---|---|
| Recordatorios locales | `UNUserNotificationCenter` |
| Despertar y dormir | AlarmKit bajo `if #available`, con **fallback completo** a notificación local |
| Identificador | `"\(activity.id.uuidString)#\(offsetIndex)"` — determinista, cancelable |
| Acciones de categoría | completar · posponer · reprogramar · abrir |
| Fecha | `DateComponents` con `Calendar` y `TimeZone` explícitos |
| Al editar o borrar | **cancelar antes de programar**, siempre |
| Al arrancar | reconciliar con `getPendingNotificationRequests()` |
| Critical Alerts | **No** en el MVP |

### Por qué el identificador es determinista

Un UUID aleatorio por notificación haría imposible cancelarla al editar la actividad, y la usuaria recibiría la alerta antigua y la nueva. El prefijo estable permite cancelar todas las de una actividad de una sola vez.

### Zona horaria y horario de verano

Toda programación usa `DateComponents` derivados de un `Calendar` con `TimeZone` explícito. Si Fer viaja, la agenda y las alertas deben seguir siendo correctas. Hay pruebas de dominio que fijan este comportamiento para el score; la Fase 4 añadirá las equivalentes para las notificaciones.

## Sonidos (§8.3)

| ID | Nombre | Archivo |
|---|---|---|
| `amanecer` | Amanecer | `amanecer.caf` |
| `campanita` | Campanita | `campanita.caf` |
| `destello` | Destello | `destello.caf` |
| `flor` | Flor | `flor.caf` |
| `luna` | Luna | `luna.caf` |
| `sueno` | Sueño | `sueno.caf` |

Más `sistema` (sonido por defecto de iOS) y `silencio`.

**Estado real: los seis archivos de audio NO existen todavía.** No se han incluido placeholders para no simular una entrega. `FerneSound.isAvailable` comprueba el bundle de verdad, y la pantalla de Perfil ya muestra "Pendiente" en lugar de "Listo" para cada uno. Hasta que existan, la app cae al sonido del sistema.

Requisitos: originales o con licencia de distribución comercial; `.caf` PCM lineal; máximo 30 s efectivos para `UNNotificationSound`. Ver `FERNE/Resources/Sounds/README.md`.

- Preview desde Ajustes.
- Selección global y por actividad.
- Haptic configurable e independiente.

## Centro de salud de notificaciones (§8.4)

La pantalla 25 debe mostrar, con datos reales del sistema:

- Permiso de alertas (`authorizationStatus`, `alertSetting`).
- Permiso de sonido (`soundSetting`).
- Disponibilidad de AlarmKit en esta versión de iOS.
- Próxima notificación programada, con su fecha real.
- Botón **Probar notificación** (disparo a +5 s).
- Enlace a Ajustes de iOS si algo está bloqueado.

## Verificación

`/test-notifications` recorre todo lo anterior. **El simulador no basta**: el resumen programado, los modos de concentración y las alarmas prominentes solo se comportan realmente en un iPhone físico.
