# Motor de score

Implementación: `FERNE/Domain/Score/`. Pruebas: `FERNETests/Domain/ScoreEngineTests.swift`.
Verificable en cualquier sistema con `bash Scripts/verify-logic.sh`.

## Score diario (§9.1)

```
score diario = completadas / actividades evaluables × 100
```

**Qué entra al denominador**

| Estado | ¿Evaluable? | Motivo |
|---|---|---|
| programada | sí | Está en el día y aún puede completarse. |
| completada | sí | Numerador y denominador. |
| pendiente | sí | Cuenta, pero sin castigo en el lenguaje. |
| omitida | sí | Se decidió no hacerla; sigue siendo parte del día. |
| **cancelada** | **no** | La especificación la excluye explícitamente. |
| **reprogramada** | **no** | Se informa aparte. Mover algo no es fracasar. |

**Día sin actividades:** `rawPercentage = 0` pero `hasData = false`. La UI **debe** distinguirlos: un día vacío no es un día al 0%.

**Precisión:** `rawPercentage` conserva el `Double` completo. El redondeo ocurre solo en `displayPercentage`. Redondear dentro del dominio arrastraría el error a la media semanal.

**Cruce de medianoche:** una actividad pertenece al día natural de su `startDate`, calculado con `calendar.startOfDay(for:)`. "Dormir a las 23:45" es del día que termina; una nota a las 00:20 es del día que empieza.

**Zonas horarias:** el `Calendar` (con su `TimeZone`) se inyecta siempre. El mismo instante puede pertenecer a días distintos según la zona, y eso es correcto: hay una prueba que lo fija (Bogotá vs Madrid).

## Constancia semanal (§9.2)

```
semanal = diario×0.40 + rutinas×0.20 + horarios importantes×0.20 + compromisos×0.20
```

| Componente | Qué mide |
|---|---|
| Cumplimiento diario | Media de los scores diarios **de los días con datos**. |
| Rutinas | Cumplimiento de actividades de categoría `rutina`. |
| Horarios importantes | `despertar`, `comida`, `dormir`. |
| Compromisos semanales | `gym`, `live`, `lectura`. |

**Decisión: los días sin datos se ignoran.** Una semana parcial (por ejemplo, es miércoles) se evalúa solo sobre lo transcurrido. Contar los días futuros como 0% daría un score falso y desalentador.

**Decisión: una categoría no programada devuelve 100, no 0.** Si Fer no programó gym esta semana, no ha incumplido nada; no hay nada que incumplir. Penalizarlo convertiría el score en un juicio sobre lo que "debería" hacer, que es exactamente lo que la especificación prohíbe.

## Estados (§9.2)

| Rango | Mensaje |
|---|---|
| 90–100 | Semana excelente |
| 75–89 | Vas muy bien |
| 60–74 | Sigues avanzando |
| < 60 | Vamos a reorganizarlo |

## Explicabilidad (pantalla 38)

`WeeklyScore.breakdown` devuelve etiqueta, valor y peso de cada componente. La pantalla de detalle debe poder explicar de dónde sale cada punto.

Disclaimer obligatorio, literal:

> Tu score no es una calificación personal. Solo sirve para ayudarte a organizar mejor tu semana.

## Lenguaje (§9.3)

`ScoreLanguage.forbiddenTerms` lista el vocabulario prohibido. La detección ignora tildes y mayúsculas. Hay pruebas que recorren **todos** los mensajes de estado y **todos** los nombres de estado de actividad para comprobar que ninguno lo usa.

Formato obligatorio de recomendación (`Recommendation`): observación verificable → explicación breve → cambio pequeño → acción opcional. El tipo no permite construir una recomendación sin los tres primeros.

## Casos de prueba obligatorios (§9.4)

| # | Caso | Prueba |
|---|---|---|
| 1 | Día sin actividades | `testDayWithoutActivitiesHasNoDataAndDoesNotScoreZeroAsFailure` |
| 2 | Todas completadas | `testAllCompletedGivesOneHundred` |
| 3 | Algunas reprogramadas | `testRescheduledActivitiesAreReportedApartAndDoNotLowerTheScore` |
| 4 | Actividad cancelada | `testCancelledActivitiesAreExcludedFromDenominator` |
| 5 | Cruce de medianoche | `testActivityJustAfterMidnightBelongsToTheNewDay` |
| 6 | Cambio de zona horaria | `testSameInstantCanBelongToDifferentDaysAcrossTimeZones` |
| 7 | Semana parcial | `testPartialWeekIgnoresDaysWithoutData` |
| 8 | Histórico modificado | `testEditingHistoricalDataRecalculatesTheScore` |

**Estado actual: 8/8 en verde.**
