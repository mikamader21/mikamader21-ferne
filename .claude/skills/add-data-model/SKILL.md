---
name: add-data-model
description: Añade o modifica una entidad de datos de FERNÉ con su migración de SwiftData. Úsalo al crear un @Model nuevo o al cambiar cualquier modelo existente.
---

# /add-data-model

## Cuándo usarlo
Al añadir, renombrar o cambiar cualquier campo de un modelo persistido.

## Entradas
- Nombre de la entidad y sus campos, tomados de `docs/DATA_MODELS.md`.
- Si sustituye o extiende algo ya existente.

## Procedimiento
1. Define primero el `struct` puro en `Domain/Entities/` (Foundation, `Sendable`, `Codable`).
2. Crea el `@Model` en `Data/Persistence/` y la proyección `toSnapshot()`.
3. **Antes** de tocar un modelo existente: crea la nueva `VersionedSchema` y su `MigrationStage` en el `SchemaMigrationPlan`.
4. Añade el repositorio correspondiente; las vistas no consultan SwiftData directamente.
5. Escribe la prueba: guardar → recrear el contenedor → leer → comparar.
6. Escribe la prueba de migración con datos del esquema anterior.
7. Actualiza `docs/DATA_MODELS.md`.

## Validaciones
- [ ] Esquema versionado y plan de migración actualizado.
- [ ] `rawValue` de enums sin cambios (o migración explícita de los datos).
- [ ] Datos preexistentes sobreviven a la migración.
- [ ] Funciona con iCloud desactivado.

## Fallos comunes
- Cambiar un `@Model` sin migración: pérdida de datos en el dispositivo de la usuaria.
- Renombrar el `rawValue` de un enum persistido.
- Marcar un campo como no opcional sin valor por defecto para los registros antiguos.
- Usar `deleteAllData()` para "arreglar" una migración. **Prohibido.**

## Definición de terminado
Modelo, migración, repositorio, pruebas de persistencia y de migración, y documentación actualizada.
