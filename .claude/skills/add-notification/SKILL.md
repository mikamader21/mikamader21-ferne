---
name: add-notification
description: Programa, reprograma o cancela una alerta local de FERNÉ. Úsalo al conectar una actividad con UserNotifications o AlarmKit, o al cambiar la lógica de recordatorios.
---

# /add-notification

## Cuándo usarlo
Al crear o modificar cualquier alerta: recordatorio, comida, gym, live, lectura, pago, despertar o dormir.

## Entradas
- Actividad (categoría, fecha, `reminderOffsets`, `soundID`, `priority`, `requiresConfirmation`).
- Si es despertar o dormir (⇒ candidata a AlarmKit).

## Procedimiento
1. Comprueba el permiso con `notificationSettings()`. Si no está concedido, **no prometas nada en la UI**: muestra el estado real y el enlace a Ajustes.
2. **Cancela primero** todos los identificadores previos de esa actividad (`"\(id)#*"`), luego programa.
3. Construye el `DateComponents` con `Calendar` y `TimeZone` explícitos.
4. Asigna la categoría con acciones: completar, posponer, reprogramar, abrir.
5. Sonido: solo si `FerneSound.isAvailable`; si no, sonido del sistema y decirlo.
6. Si es despertar/dormir y AlarmKit está disponible (`if #available`), úsalo; en caso contrario, fallback a notificación local. Ambos caminos deben funcionar.
7. Registra en `FerneLog.notifications` **sin datos personales**: id y categoría, nunca el título.

## Validaciones
- [ ] Sin duplicados tras editar dos veces seguidas.
- [ ] Cancelación efectiva al borrar la actividad.
- [ ] Correcto con cambio de zona horaria y horario de verano.
- [ ] La UI refleja el permiso real.

## Fallos comunes
- Programar sin cancelar ⇒ la usuaria recibe la alerta dos veces.
- Identificadores aleatorios ⇒ imposible cancelar.
- Usar la hora local del dispositivo sin `TimeZone` explícito.
- Prometer un sonido cuyo archivo no está en el bundle.

## Definición de terminado
Programa, reprograma y cancela correctamente; probado en **dispositivo real**; sin duplicados; con prueba automatizada usando un doble del centro de notificaciones.
