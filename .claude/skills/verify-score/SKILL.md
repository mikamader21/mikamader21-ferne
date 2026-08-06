---
name: verify-score
description: Verifica el motor de score de FERNÉ contra los ocho casos obligatorios de la especificación. Úsalo tras tocar ScoreEngine, las reglas de estado o cualquier cálculo de progreso.
---

# /verify-score

## Cuándo usarlo
Tras cualquier cambio en `Domain/Score/`, en `ActivityStatus` o en la lógica de completar/reprogramar.

## Entradas
Ninguna. El skill ejecuta la batería completa.

## Procedimiento
1. Ejecuta `bash Scripts/verify-logic.sh` y transcribe el recuento real de pruebas.
2. Confirma que los ocho casos de §9.4 siguen cubiertos:
   1. Día sin actividades → sin datos, no 0% de fracaso.
   2. Todas completadas → 100%.
   3. Algunas reprogramadas → informadas aparte, sin bajar el score.
   4. Actividad cancelada → fuera del denominador.
   5. Cruce de medianoche → pertenece al día de su `startDate`.
   6. Cambio de zona horaria → el mismo instante puede caer en días distintos.
   7. Semana parcial → los días sin datos no arrastran la media.
   8. Histórico modificado → el score se recalcula.
3. Comprueba que los pesos semanales suman 1.0 (40/20/20/20).
4. Comprueba los umbrales: 90+, 75–89, 60–74, <60.
5. Comprueba que todo texto visible pasa `ScoreLanguage`.
6. Comprueba que el desglose (`breakdown`) explica cada componente: el score **siempre** debe poder explicarse.

## Validaciones
- [ ] 8/8 casos en verde.
- [ ] Precisión interna conservada, redondeo solo en presentación.
- [ ] Ninguna cadena con vocabulario punitivo.
- [ ] El disclaimer del score está presente.

## Fallos comunes
- Contar las reprogramadas como incumplidas.
- Convertir un día vacío en 0%.
- Redondear dentro del dominio y arrastrar el error a la semana.
- Penalizar una categoría que la usuaria simplemente no programó.

## Definición de terminado
Salida real de las pruebas con 0 fallos y confirmación explícita de los ocho casos.
