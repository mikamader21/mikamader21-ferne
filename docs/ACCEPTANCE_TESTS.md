# Criterios de aceptación

## Criterio final (§17)

FERNÉ está lista cuando:

| # | Criterio | Estado |
|---|---|---|
| 1 | Las 40 pantallas existen y están conectadas | ⬜ Fases 2–7 |
| 2 | El MVP funciona en un iPhone real | ⬜ Fase 8 |
| 3 | Las alertas se programan, actualizan y cancelan correctamente | ⬜ Fase 4 |
| 4 | Fer puede escuchar y escoger sonidos | ⬜ Fase 4 · **bloqueado: faltan los archivos de audio** |
| 5 | Los datos sobreviven reinicios y uso offline | ⬜ Fase 1 |
| 6 | El score explica sus cálculos | 🟡 motor y desglose listos; pantalla 38 en Fase 5 |
| 7 | El diseño conserva sol, luna, rosados, ciruela, profundidad y movimiento | 🟡 base lista y verificada por script |
| 8 | La app respeta accesibilidad | 🟡 base lista; auditoría por pantalla en cada fase |
| 9 | No existen secretos en el repositorio | ✅ verificado |
| 10 | Tests y quality gates pasan | 🟡 40/40 de dominio; falta build iOS |
| 11 | Hay instrucciones de build, firma y TestFlight | ✅ `docs/BUILD.md` + `/prepare-testflight` |
| 12 | La implementación coincide con las referencias visuales aprobadas | ⬜ **bloqueado: no se han recibido las referencias** |

## MVP entregable (§16)

| Requisito | Fase |
|---|---|
| Abrir sin cuenta | 0 ✅ |
| Onboarding y permisos | 2 |
| Inicio con saludo día/noche | 0 🟡 (esqueleto) · 2 (completo) |
| Crear, editar, completar y reprogramar actividades | 1 |
| Agenda | 2 |
| Comidas, gym, live, lectura, pagos y dormir | 3 |
| Notificaciones locales con sonidos seleccionables | 4 |
| AlarmKit/fallback para despertar y dormir | 4 |
| Datos persistentes | 1 |
| Score diario/semanal | 0 ✅ (motor) · 5 (pantallas) |
| Ajustes y prueba de notificación | 4 |
| Funcionamiento offline | 1 |
| Instalación firmada en iPhone | 8 |

## Definición de "terminado" para una pantalla

Ninguna pantalla se acepta sin las siete:

1. Compila sin warnings nuevos.
2. Estados normal, vacío, cargando, error implementados.
3. Escena verificada en mañana y en noche (`/verify-design` **APRUEBA**).
4. Accesibilidad auditada (`/audit-accessibility`).
5. Pruebas escritas y en verde.
6. Persistencia comprobada si toca datos.
7. Documentación y checklist actualizados.
