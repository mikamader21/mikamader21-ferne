# Catálogo de 40 pantallas

Cada pantalla debe implementarse con estados **normal, vacío, cargando, error** y accesibilidad cuando corresponda.

Leyenda: ✅ implementada y verificada · 🟡 esqueleto de Fase 0 · ⬜ pendiente

| # | Pantalla | Fase | Estado | Archivo |
|---:|---|---:|:---:|---|
| 01 | Splash cinematográfico | 2 | 🟡 | `Features/Onboarding/SplashView.swift` |
| 02 | Bienvenida | 2 | ⬜ | |
| 03 | Permisos | 2 | ⬜ | |
| 04 | Inicio / Hoy | 2 | 🟡 | `Features/Home/HomeView.swift` |
| 05 | Mensaje diario | 5 | ⬜ | |
| 06 | Menú Agregar | 2 | ⬜ | |
| 07 | Nuevo recordatorio | 2 | ⬜ | |
| 08 | Agenda diaria | 2 | ⬜ | |
| 09 | Agenda semanal | 2 | ⬜ | |
| 10 | Calendario mensual | 2 | ⬜ | |
| 11 | Horarios de comida | 3 | ⬜ | |
| 12 | Agregar comida | 3 | ⬜ | |
| 13 | Gym | 3 | ⬜ | |
| 14 | Agregar gym | 3 | ⬜ | |
| 15 | TikTok Live | 3 | ⬜ | |
| 16 | Agregar TikTok Live | 3 | ⬜ | |
| 17 | Lectura | 3 | ⬜ | |
| 18 | Agregar lectura | 3 | ⬜ | |
| 19 | Pagos y recibos | 3 | ⬜ | |
| 20 | Agregar pago | 3 | ⬜ | |
| 21 | Mis rutinas | 3 | ⬜ | |
| 22 | Detalle de rutina | 3 | ⬜ | |
| 23 | Hora de dormir | 3 | ⬜ | |
| 24 | Alarma activa | 4 | ⬜ | |
| 25 | Centro de notificaciones | 4 | ⬜ | |
| 26 | Para mí | 6 | ⬜ | |
| 27 | Registro del día | 6 | ⬜ | |
| 28 | Perfil y ajustes | 6 | 🟡 | `Features/Profile/ProfileView.swift` |
| 29 | Personalizar saludo | 6 | 🟡 | dentro de `ProfileView` |
| 30 | Integraciones de IA | 6 | ⬜ | |
| 31 | Importar historial | 6 | ⬜ | |
| 32 | Privacidad y datos | 6 | ⬜ | |
| 33 | Detalle de actividad | 1 | ⬜ | |
| 34 | Reprogramar | 1 | ⬜ | |
| 35 | Día completado | 7 | ⬜ | |
| 36 | Mi progreso | 5 | 🟡 | `Features/Progress/ProgressView.swift` |
| 37 | Resumen del día | 5 | ⬜ | |
| 38 | Detalle del score | 5 | 🟡 | desglose dentro de `ProgressView` |
| 39 | Recomendaciones FERNÉ | 5 | 🟡 | `Features/Sparks/SparksView.swift` |
| 40 | Celebración semanal | 5 | ⬜ | |

**Recuento: 0 completas · 7 con esqueleto · 33 pendientes.**

> El esqueleto de Fase 0 no cuenta como pantalla entregada. Existe para validar la arquitectura, el sistema de diseño y la navegación, no para simular avance.

## Detalle por pantalla

El contenido normativo de cada una está en [`MASTER_SPEC.md`](MASTER_SPEC.md) §6. **No se resume aquí a propósito**: resumir la especificación es la vía habitual para perder un requisito. Al construir una pantalla, lee su sección original.

Antes de implementar, el agente `product-architect` traduce esa sección en requisitos verificables con copy literal.
