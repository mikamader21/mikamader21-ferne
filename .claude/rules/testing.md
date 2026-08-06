# Regla · Pruebas

Aplica a: `FERNETests/**`, `FERNEUITests/**`

## Qué debe tener prueba

- Todo cálculo del score (§9.4 define ocho casos obligatorios; todos están cubiertos y deben seguir estándolo).
- Toda regla horaria (franjas de tema, recurrencias, cruce de medianoche, zonas horarias).
- Todo texto visible generado por código pasa por `ScoreLanguage`.
- Programación y cancelación de notificaciones (con un doble de `UNUserNotificationCenter`).
- Persistencia: guardar → reiniciar contenedor → leer.

## Cómo

- Las pruebas de dominio se escriben con el `#if canImport(FERNE)` de `TestSupport.swift`, para que corran tanto en Xcode como con `Scripts/verify-logic.sh`.
- Fechas siempre construidas con `TestSupport.date(...)` y calendario explícito. Prohibido `Date()` en una aserción.
- Un test por comportamiento, con nombre que describa la regla de negocio, no la función.

## Prohibido

- Declarar una feature terminada con tests en rojo, saltados o comentados.
- Ocultar un fallo cambiando la aserción en lugar del código.
