# Regla · Notificaciones y alarmas

Aplica a: `FERNE/Services/Notifications/**`, cualquier vista que muestre estado de alertas

## Honestidad ante todo

La UI **no puede prometer** que una alerta sonará si iOS no concedió el permiso.
Antes de mostrar "te avisaré a las 7:00", consultar `UNUserNotificationCenter.notificationSettings()`.
Si el permiso está denegado, mostrar el estado real y un enlace a Ajustes de iOS.

## Implementación

- `UNUserNotificationCenter` para todo recordatorio local.
- AlarmKit **solo** para despertar y dormir, bajo `if #available`, con fallback completo a notificación local.
- Categorías con acciones: completar, posponer, reprogramar, abrir.
- Al editar o borrar una actividad: **cancelar primero** los identificadores anteriores y luego programar los nuevos. Nunca programar sin cancelar (duplicados).
- Identificador determinista: `"\(activity.id.uuidString)#\(offsetIndex)"`.
- Reconciliar la agenda al arrancar la app (`getPendingNotificationRequests`).
- Usar `DateComponents` con `Calendar` y `TimeZone` explícitos: cambios de zona y horario de verano deben resolverse bien.
- Sin Critical Alerts en el MVP.

## Sonidos

- Solo `.caf` presentes en el bundle. `FerneSound.isAvailable` decide si se ofrece.
- Si el archivo no existe, caer al sonido del sistema y **decirlo** en la UI.
