# Regla · Persistencia

Aplica a: `FERNE/Data/**`

- SwiftData es la única fuente de verdad local. `AppStorage` solo para preferencias simples de UI.
- **Esquema versionado desde el primer commit** (`VersionedSchema` + `SchemaMigrationPlan`).
- Antes de cambiar cualquier `@Model`: escribir la migración. Nunca "borrar y recrear" como solución.
- Los `rawValue` de los enums persistidos son contrato: renombrarlos rompe los datos guardados.
- Todo acceso a datos pasa por un repositorio; las vistas no ejecutan `FetchDescriptor` a mano.
- CloudKit es **opcional**: la app debe funcionar completa con iCloud desactivado y sin conexión.
- Prueba obligatoria antes de aceptar una feature: cerrar la app, reabrirla y comprobar que los datos siguen.
