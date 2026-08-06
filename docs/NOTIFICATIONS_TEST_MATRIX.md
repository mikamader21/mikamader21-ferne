# Clasificación de pruebas de notificaciones

Las notificaciones son la función de la que depende la confianza de Fer en FERNÉ. También son
la que **menos** se puede verificar sin un iPhone.

Este documento clasifica cada prueba por dónde puede ejecutarse de verdad. La regla es simple:
**una prueba solo se marca aprobada en el entorno donde su resultado significa algo.**

Lo que se conserva sin cambios: `UserNotifications`, AlarmKit cuando esté disponible, el
fallback completo, los sonidos seleccionables y el centro de salud de notificaciones.

---

## Nivel 1 · Verificable en CI (GitHub Actions macOS)

Pruebas unitarias con un doble de `UNUserNotificationCenter`. No necesitan simulador ni
dispositivo: comprueban **nuestra lógica**, no la entrega de iOS.

| # | Prueba | Qué verifica | Fase |
|---|---|---|---|
| C1 | Programación | Una actividad con 2 `reminderOffsets` genera exactamente 2 peticiones | 4 |
| C2 | Identificadores | El id sigue el patrón `"\(activity.id)#\(index)"` y es determinista | 4 |
| C3 | Cancelación | Borrar una actividad elimina **todas** sus peticiones, ninguna más | 4 |
| C4 | Reprogramación | Editar cancela las anteriores **antes** de programar las nuevas | 4 |
| C5 | Sin duplicados | Editar dos veces seguidas deja el mismo número de peticiones, no el doble | 4 |
| C6 | Recurrencias | Una regla semanal genera disparos en los días correctos | 4 |
| C7 | Zona horaria | Los `DateComponents` usan el `TimeZone` inyectado, no el del sistema | 4 |
| C8 | Horario de verano | Un cambio de hora no desplaza la alerta | 4 |
| C9 | Selección de sonido | Se asigna el `soundID` correcto; si el `.caf` no existe, cae al del sistema | 4 |
| C10 | Estado de permisos simulado | Con permiso denegado, la UI **no** afirma que sonará | 4 |
| C11 | Categorías y acciones | Cada categoría registra completar, posponer, reprogramar y abrir | 4 |
| C12 | Reconciliación al arrancar | Se detectan y limpian peticiones huérfanas | 4 |
| C13 | Prioridad de despertar/dormir | Solo `Priority.esencial` solicita alarma prominente | 4 |

**Estado: pendientes de la Fase 4.** Hoy existe la política, no el código.

---

## Nivel 2 · Verificable en simulador remoto (Appetize)

Lo que se puede *mirar*, no lo que se puede *garantizar*.

| # | Prueba | Qué verifica | Limitación |
|---|---|---|---|
| S1 | Presentación visual | La notificación aparece con su texto e icono | Sin pantalla bloqueada real |
| S2 | Navegación desde acciones | Tocar "Completar" abre la pantalla correcta | El estado del simulador no persiste |
| S3 | Pantalla 25 · centro de salud | Muestra el estado real de los permisos del simulador | Los permisos del simulador son triviales de conceder |
| S4 | Pantalla 24 · alarma activa | Diseño de la presentación prominente | AlarmKit no se comporta como en un dispositivo |
| S5 | Preview de sonido en Ajustes | El botón dispara la reproducción | El audio remoto no es fiable |
| S6 | Diálogo de permisos | Aparece con el texto correcto y en el momento correcto | — |
| S7 | Flujo de permiso denegado | La app explica y ofrece el enlace a Ajustes | — |

**Estado: pendiente. Requiere el primer build en Appetize.**

---

## Nivel 3 · Exigen el iPhone real de Fer

**Ninguna de estas puede marcarse aprobada sin un dispositivo físico.** No hay atajo, no hay
sustituto y no se van a dar por buenas basándose en el simulador.

| # | Prueba | Por qué necesita hardware |
|---|---|---|
| D1 | Entrega en segundo plano | El planificador de iOS solo se comporta así en un dispositivo con uso real |
| D2 | Pantalla bloqueada | La presentación y el agrupado cambian por completo |
| D3 | Modo silencio | Determina si suena o solo vibra |
| D4 | Modos de concentración | Pueden suprimir o retrasar la alerta según la configuración de Fer |
| D5 | Resumen programado | Si está activo, la notificación puede llegar horas más tarde |
| D6 | AlarmKit real | Las alarmas prominentes exigen el entitlement concedido y hardware |
| D7 | Volumen y calidad de sonido | Los seis sonidos deben ser audibles y agradables al despertar |
| D8 | Haptics | El hardware no existe en ningún simulador |
| D9 | Batería y actividad en segundo plano | Solo medible en uso real |
| D10 | Persistencia tras reiniciar el iPhone | Las notificaciones deben sobrevivir al reinicio |
| D11 | Cambio de zona horaria viajando | Con el cambio automático de iOS activo |
| D12 | Notificación con la app cerrada por el usuario | iOS trata este caso de forma distinta |

**Estado: NO VERIFICADO. Permanentemente, hasta que exista un iPhone.**

---

## Cómo se reporta cada nivel

| Situación | Cómo se escribe |
|---|---|
| Prueba de nivel 1 en verde | ✅ **Aprobada** |
| Prueba de nivel 2 revisada en Appetize | 🟡 **Revisada visualmente** — nunca ✅ |
| Prueba de nivel 3 sin dispositivo | ⬜ **NO VERIFICADO** |
| Prueba de nivel 3 ejecutada en el iPhone de Fer | ✅ **Aprobada**, con fecha y modelo |

**Prohibido:** escribir "las notificaciones funcionan" apoyándose en niveles 1 y 2. Lo correcto
es: *"la lógica de programación y cancelación está probada; la entrega real no se ha
verificado en dispositivo."*

---

## Consecuencia para la Fase 4

La Fase 4 **puede completarse** en la cadena Windows + CI + Appetize: el código se escribe, las
13 pruebas de nivel 1 pasan y las 7 de nivel 2 se revisan.

Lo que la Fase 4 **no puede** es declararse terminada. Queda en *"completa a falta de
validación en dispositivo"* hasta que las 12 pruebas de nivel 3 se ejecuten en el iPhone de Fer.

Esto no bloquea las Fases 5, 6 y 7. Sí bloquea la Fase 8 y cualquier entrega a Fer.

### Qué hará falta el día que haya un iPhone

1. Un iPhone con iOS 18 o superior.
2. Una cuenta de Apple Developer (la gratuita sirve; el perfil caduca a los 7 días).
3. Un Mac **o** el servicio de firma que decidamos entonces. Instalar en un dispositivo real
   requiere firma, y eso GitHub Actions puede hacerlo con certificados guardados como
   secrets — cuando lo autorices.
4. Recorrer las 12 pruebas D1–D12 y registrar el resultado con fecha y modelo.
