---
name: test-notifications
description: Verifica el estado de salud de las notificaciones de FERNÉ. Úsalo para comprobar permisos, sonidos, próxima alerta programada, estado de AlarmKit y para el botón "Probar notificación".
---

# /test-notifications

## Cuándo usarlo
Antes de cerrar la Fase 4, al depurar una alerta que no llega, y como parte del quality gate.

## Antes de nada: en qué nivel estás

`docs/NOTIFICATIONS_TEST_MATRIX.md` clasifica cada prueba. Empieza identificando el nivel,
porque determina cómo puedes reportar el resultado:

- **Nivel 1** (13 pruebas de lógica) → CI. Se reportan ✅.
- **Nivel 2** (7 pruebas de presentación) → Appetize. Se reportan 🟡, **jamás** ✅.
- **Nivel 3** (12 pruebas de entrega real) → iPhone físico. Hoy: ⬜ NO VERIFICADO.

No hay iPhone. Todo el nivel 3 seguirá sin verificar.

## Entradas
Ninguna. Opcionalmente, el identificador de una actividad concreta.

## Procedimiento
1. Lee `notificationSettings()` y reporta, uno a uno: `authorizationStatus`, `alertSetting`, `soundSetting`, `badgeSetting`, `criticalAlertSetting`, `scheduledDeliverySetting` (resumen programado) y `timeSensitiveSetting`.
2. Comprueba la disponibilidad real de AlarmKit en la versión de iOS del dispositivo.
3. Lista `getPendingNotificationRequests()` y muestra la próxima alerta con su fecha real de disparo.
4. Detecta duplicados: dos peticiones con el mismo prefijo de identificador.
5. Ofrece `Probar notificación` (disparo a +5 s) y confirma su llegada.
6. Verifica qué sonidos existen realmente en el bundle (`SoundLibrary.available`).

## Validaciones
- [ ] El estado mostrado coincide con el de Ajustes de iOS.
- [ ] Si el permiso está denegado, la UI **no** promete entrega y ofrece el enlace a Ajustes.
- [ ] Sin duplicados pendientes.
- [ ] La próxima alerta mostrada coincide con la real.

## Fallos comunes
- Probar en simulador y dar por buena la entrega: el resumen programado y el modo concentración solo se comportan de verdad en dispositivo.
- Mostrar "activado" porque la app pidió permiso, sin volver a consultar el estado.
- Ignorar que el usuario puede haber desactivado solo el sonido.

## Definición de terminado
Informe con: el estado real de cada permiso, la próxima alerta programada, los sonidos
realmente presentes en el bundle, el resultado de las pruebas de nivel 1, lo revisado en
Appetize (nivel 2) y la lista explícita de las 12 pruebas de nivel 3 que siguen en
NO VERIFICADO.

**Nunca** cierres el informe con "las notificaciones funcionan".
