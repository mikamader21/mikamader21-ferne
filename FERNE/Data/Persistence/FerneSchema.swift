import Foundation
import SwiftData

/// Esquema versionado desde el primer commit (MASTER_SPEC §7.3).
///
/// Aunque hoy solo exista una versión, el plan de migración ya está en su sitio:
/// añadirlo después, con datos reales en el dispositivo de Fer, es mucho más caro.
public enum FerneSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    public static var models: [any PersistentModel.Type] {
        [ActivityRecord.self]
    }
}

public enum FerneMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [FerneSchemaV1.self]
    }

    /// Vacío mientras solo haya una versión. Cada cambio de modelo añade aquí su
    /// etapa **antes** de tocar el modelo. Nunca se borran datos para resolver una
    /// migración fallida.
    public static var stages: [MigrationStage] {
        []
    }
}
