# Plan de QA

## Quality gate (§14.1)

Se ejecuta con `bash Scripts/quality-gate.sh`. El script reporta explícitamente lo que **no pudo** verificar en el entorno actual; nunca declara éxito por omisión.

| # | Comprobación | Automatizable |
|---|---|---|
| 1 | Compila sin warnings nuevos | sí (macOS) |
| 2 | Tests unitarios pasan | sí |
| 3 | UI tests críticos pasan | sí (macOS) |
| 4 | Sin crashes | parcial |
| 5 | Persistencia tras reinicio | sí (prueba de contenedor) |
| 6 | Notificaciones verificadas **en dispositivo** | **no** |
| 7 | VoiceOver y Dynamic Type | parcial |
| 8 | Reduce Motion | parcial |
| 9 | Comparación visual contra diseño | **no** |
| 10 | Sin secretos | sí (`design-guard.sh`) |

Los puntos 6 y 9 requieren a una persona con un iPhone. Se reportan como **NO VERIFICADO** hasta que alguien los confirme.

## Casos críticos E2E (§14.2)

| # | Caso | Fase que lo habilita |
|---|---|---|
| 1 | Crear actividad → aparece en Inicio y Agenda → notifica → completar → el score cambia | 4 |
| 2 | Reprogramar → la notificación anterior se cancela → se programa la nueva | 4 |
| 3 | Crear pago recurrente → aviso anticipado → marcar pagado | 4 |
| 4 | Crear rutina → completar pasos → el progreso se actualiza | 3 |
| 5 | Configurar despertar/dormir → alarma compatible o fallback | 4 |
| 6 | Cerrar y abrir la app → los datos permanecen | 1 |
| 7 | Sin internet → las funciones centrales operan | 1 |
| 8 | Permisos denegados → la app lo explica y permite corregir | 4 |
| 9 | Cambio de hora o de zona → agenda y alertas correctas | 4 |
| 10 | Activar Reduce Motion → las escenas se simplifican **sin perder el astro** | 7 |

## QA visual (§14.3)

Para cada pantalla aceptada:

- Captura en tamaño de texto **compacto**, **estándar** y **accesibilidad grande**.
- Captura en **mañana**, **tarde** y **noche**.
- Comparación de jerarquía, paleta, espaciado y estados contra la referencia aprobada.

**Rechazo automático:** cualquier pantalla con fondo plano genérico.

Las posiciones de estrellas y partículas son deterministas para que las capturas sean comparables entre ejecuciones.

## Verificación sin Xcode

`bash Scripts/verify-logic.sh` compila y prueba `Domain/` con cualquier toolchain de Swift, también en Linux. Cubre score, franjas horarias, recurrencias y lenguaje. **No sustituye** a `make test`, que sigue siendo obligatorio para la app completa.

`bash Scripts/design-guard.sh` verifica sin compilar: negro puro, hex fuera de tokens, pureza de la capa Domain, vocabulario punitivo, secretos, `print(` y fondos planos.
