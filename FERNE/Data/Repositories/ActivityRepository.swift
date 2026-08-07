import Foundation
import SwiftData

/// Único punto de acceso a las actividades. Las vistas no ejecutan `FetchDescriptor`.
@MainActor
public struct ActivityRepository {
    private let context: ModelContext
    private let calendar: Calendar

    public init(context: ModelContext, calendar: Calendar = .ferneDefault) {
        self.context = context
        self.calendar = calendar
    }

    // MARK: - Escritura

    @discardableResult
    public func create(_ record: ActivityRecord) -> ActivityRecord {
        context.insert(record)
        save()
        FerneLog.data.info("Actividad creada · categoría \(record.categoryRaw, privacy: .public)")
        return record
    }

    /// Marca como completada. Idempotente: volver a llamarla no altera `completedAt`.
    public func complete(_ record: ActivityRecord, at date: Date = Date()) {
        guard record.status != .completada else { return }
        record.status = .completada
        record.completedAt = date
        record.updatedAt = date
        save()
    }

    /// Devuelve una actividad completada a pendiente.
    public func uncomplete(_ record: ActivityRecord) {
        guard record.status == .completada else { return }
        record.status = .pendiente
        record.completedAt = nil
        record.updatedAt = Date()
        save()
    }

    /// Reprogramar conserva la fecha original y **no** cuenta como fracaso (§9.1).
    public func reschedule(_ record: ActivityRecord, to newDate: Date) {
        record.rescheduledFrom = record.startDate
        record.startDate = newDate
        record.status = .programada
        record.updatedAt = Date()
        save()
    }

    public func delete(_ record: ActivityRecord) {
        context.delete(record)
        save()
    }

    /// Borrado total. Solo desde Perfil, con doble confirmación.
    public func deleteAll() {
        let all = (try? context.fetch(FetchDescriptor<ActivityRecord>())) ?? []
        for record in all {
            context.delete(record)
        }
        save()
        FerneLog.data.info("Se eliminaron \(all.count, privacy: .public) actividades a petición del usuario")
    }

    private func save() {
        do {
            try context.save()
        } catch {
            FerneLog.data.error("No se pudo guardar: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Consulta

    public func all() -> [ActivityRecord] {
        let descriptor = FetchDescriptor<ActivityRecord>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}

// MARK: - Utilidades de agrupación

public enum ActivityGrouping {
    /// Actividades de un día natural concreto.
    public static func onDay(_ day: Date, from records: [ActivityRecord], calendar: Calendar = .ferneDefault) -> [ActivityRecord] {
        let target = calendar.startOfDay(for: day)
        return records
            .filter { calendar.startOfDay(for: $0.startDate) == target }
            .sorted { $0.startDate < $1.startDate }
    }

    /// La siguiente actividad pendiente a partir de un instante.
    public static func next(after date: Date, from records: [ActivityRecord]) -> ActivityRecord? {
        records
            .filter { $0.startDate > date && $0.status != .completada && $0.status != .cancelada }
            .min { $0.startDate < $1.startDate }
    }
}
