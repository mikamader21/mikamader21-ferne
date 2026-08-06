---
name: run-quality-gate
description: Ejecuta el quality gate completo de FERNÉ. Úsalo al final de cada fase y antes de declarar cualquier trabajo terminado.
---

# /run-quality-gate

## Cuándo usarlo
Al cerrar una fase, antes de proponer un commit y antes de decir que algo está listo.

## Entradas
Fase o feature que se está cerrando.

## Procedimiento
1. Ejecuta `bash Scripts/quality-gate.sh`. Cubre 8 pasos: integridad del spec, archivos
   obligatorios, guardián de diseño, escaneo de secretos, pruebas de dominio, SwiftLint,
   compilación y pruebas.
2. Transcribe la salida **literal**, incluida la sección "OMITIDO en este entorno".
3. Consulta el estado del workflow `iOS CI` en GitHub. Desde Windows, los pasos de
   compilación y pruebas siempre aparecerán como omitidos: el resultado real está allí.
   Si el pipeline nunca se ha ejecutado, el build es **NO VERIFICADO**.
4. Recorre los diez puntos de §14.1 y marca cada uno como PASA, FALLA o **NO VERIFICADO**.
5. Ejecuta los casos E2E de §14.2 que apliquen a la fase (`docs/QA_PLAN.md`).
6. Actualiza `docs/CHECKLIST.md`, `docs/VISUAL_QA_MATRIX.md` y registra en
   `docs/DECISIONS.md`: decisiones, archivos modificados, comandos ejecutados y resultados.

## Validaciones
- [ ] Compila sin warnings nuevos evitables.
- [ ] Tests unitarios y de UI en verde.
- [ ] Persistencia comprobada tras reinicio.
- [ ] Navegación comprobada.
- [ ] Accesibilidad base comprobada.
- [ ] Sin secretos.
- [ ] Documentación actualizada.

## Fallos comunes
- Reportar "todo pasa" cuando el entorno no pudo ejecutar la mitad de los pasos.
- Dar por bueno el build porque el YAML del workflow sea válido.
- Convertir una revisión en Appetize (🟡) en una aprobación (✅).
- Silenciar un warning en lugar de arreglarlo.
- Marcar un test como saltado para que el gate quede verde.

## Definición de terminado
Informe con el resultado real de cada punto. Lo no verificable en el entorno actual se reporta como **NO VERIFICADO**, jamás como aprobado.
