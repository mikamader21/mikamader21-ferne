import Foundation
import SwiftData

/// Construye el contenedor de SwiftData.
///
/// Regla que da nombre a este archivo: **una instalación nueva arranca vacía**.
/// Los datos de demostración solo existen bajo UI tests, y en un contenedor en
/// memoria que se descarta al terminar. Producción no los ve jamás.
public enum ModelContainerFactory {
    public static func make() -> ModelContainer {
        #if DEBUG
            // El modo smoke va PRIMERO: necesita un almacén real en disco para que
            // la persistencia entre lanzamientos sea comprobable, y jamás datos
            // sembrados. Con fixtures no se probaría nada.
            if UITestConfiguration.isRuntimeSmoke {
                return makeIsolatedStore()
            }
            if UITestConfiguration.isActive {
                return makeSeededInMemory()
            }
        #endif
        return makePersistent()
    }

    #if DEBUG
        /// Almacén aislado en disco para las pruebas de humo.
        ///
        /// `-FERNEResetStore` lo borra **antes** de abrirlo; sin ese argumento se
        /// reutiliza, que es lo que permite comprobar que los datos sobreviven a un
        /// relanzamiento.
        private static func makeIsolatedStore() -> ModelContainer {
            guard let url = UITestConfiguration.runtimeSmokeStoreURL else {
                return makeEmptyInMemory()
            }
            if UITestConfiguration.resetsStore {
                let manager = FileManager.default
                for suffix in ["", "-shm", "-wal"] {
                    let path = URL(fileURLWithPath: url.path + suffix)
                    try? manager.removeItem(at: path)
                }
                UserDefaults.standard
                    .removePersistentDomain(forName: UITestConfiguration.runtimeSmokeSuiteName)
            }
            let configuration = ModelConfiguration(schema: Schema(FerneSchemaV1.models), url: url)
            do {
                return try ModelContainer(
                    for: Schema(FerneSchemaV1.models),
                    migrationPlan: FerneMigrationPlan.self,
                    configurations: configuration
                )
            } catch {
                FerneLog.data.error("Almacén aislado inaccesible: \(error.localizedDescription, privacy: .public)")
                return makeEmptyInMemory()
            }
        }
    #endif

    /// Contenedor real, en disco. Sin CloudKit por ahora: el respaldo es opcional
    /// y activarlo obliga a que todas las propiedades tengan valor por defecto.
    private static func makePersistent() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: Schema(FerneSchemaV1.models),
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: Schema(FerneSchemaV1.models),
                migrationPlan: FerneMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            FerneLog.data.error("No se pudo abrir el contenedor persistente: \(error.localizedDescription, privacy: .public)")
            // Último recurso: memoria. Se pierde la persistencia, pero la app abre
            // y Fer puede seguir usándola. NUNCA se borra el almacén existente.
            return makeEmptyInMemory()
        }
    }

    private static func makeEmptyInMemory() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: Schema(FerneSchemaV1.models),
            isStoredInMemoryOnly: true
        )
        do {
            return try ModelContainer(for: Schema(FerneSchemaV1.models), configurations: configuration)
        } catch {
            // Si ni siquiera un contenedor en memoria se puede crear, el esquema es
            // inválido: no hay nada que la app pueda hacer, y seguir en silencio
            // sería peor que detenerse con un motivo legible.
            fatalError("Esquema de SwiftData inválido: \(error)")
        }
    }

    #if DEBUG
        /// Contenedor efímero con los fixtures deterministas de las capturas.
        /// Existe **solo en Debug**: producción nunca ve datos de demostración.
        private static func makeSeededInMemory() -> ModelContainer {
            let container = makeEmptyInMemory()
            let context = ModelContext(container)
            for snapshot in ScreenshotFixtures.activities(for: UITestConfiguration.fixture) {
                context.insert(ActivityRecord(from: snapshot))
            }
            try? context.save()
            return container
        }
    #endif
}

public extension ActivityRecord {
    /// Crea un registro a partir de un snapshot del dominio. Solo lo usan los
    /// fixtures de capturas y las previews.
    convenience init(from snapshot: ActivitySnapshot) {
        self.init(
            id: snapshot.id,
            title: snapshot.title,
            notes: snapshot.notes,
            category: snapshot.category,
            startDate: snapshot.startDate,
            endDate: snapshot.endDate,
            allDay: snapshot.allDay,
            recurrence: snapshot.recurrenceRule,
            reminderOffsets: snapshot.reminderOffsets,
            soundID: snapshot.soundID,
            priority: snapshot.priority,
            requiresConfirmation: snapshot.requiresConfirmation,
            status: snapshot.status
        )
        completedAt = snapshot.completedAt
        rescheduledFrom = snapshot.rescheduledFrom
    }
}
