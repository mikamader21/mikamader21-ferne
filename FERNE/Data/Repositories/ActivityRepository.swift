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
        syncNotifications(for: record)
        FerneLog.data.info("Actividad creada · categoría \(record.categoryRaw, privacy: .public)")
        return record
    }

    /// Fer pulsó "Empezar". **No suma puntos**: empezar no es cumplir.
    public func start(_ record: ActivityRecord, at date: Date = Date()) {
        guard record.status.isOpen else { return }
        record.status = .enCurso
        record.updatedAt = date
        save()
    }

    /// Confirmación de cumplimiento.
    public func complete(_ record: ActivityRecord, at date: Date = Date()) {
        guard record.status != .completada else { return }
        record.status = .completada
        record.completedAt = date
        record.updatedAt = date
        save()
        cancelNotifications(for: record)
    }

    /// Cumplida a medias: vale la mitad de sus puntos.
    public func markPartial(_ record: ActivityRecord, at date: Date = Date()) {
        record.status = .parcial
        record.completedAt = date
        record.updatedAt = date
        save()
        cancelNotifications(for: record)
    }

    /// Fer confirmó que no la hizo. Es distinto de dejarla sin confirmar.
    public func markSkipped(_ record: ActivityRecord) {
        record.status = .omitida
        record.completedAt = nil
        record.updatedAt = Date()
        save()
        cancelNotifications(for: record)
    }

    /// Su ventana cerró sin respuesta. No es un fallo: falta la confirmación.
    public func markUnconfirmed(_ record: ActivityRecord) {
        guard record.status == .programada || record.status == .proxima || record.status == .enCurso else { return }
        record.status = .sinConfirmar
        record.updatedAt = Date()
        save()
    }

    /// Devuelve una actividad confirmada al estado abierto.
    public func reopen(_ record: ActivityRecord) {
        guard !record.status.isOpen else { return }
        record.status = .programada
        record.completedAt = nil
        record.updatedAt = Date()
        save()
    }

    /// Reprogramar conserva la fecha original y **no** cuenta como fracaso (§9.1).
    ///
    /// Cancela las alertas anteriores **antes** de programar las nuevas: es la única
    /// forma de que Fer no reciba la vieja y la nueva.
    public func reschedule(_ record: ActivityRecord, to newDate: Date) {
        record.rescheduledFrom = record.startDate
        record.rescheduleCount += 1
        record.startDate = newDate
        if let end = record.endDate {
            let duration = end.timeIntervalSince(record.rescheduledFrom ?? newDate)
            record.endDate = newDate.addingTimeInterval(max(duration, 0))
        }
        record.status = .programada
        record.updatedAt = Date()
        save()
        syncNotifications(for: record)
    }

    public func cancelActivity(_ record: ActivityRecord) {
        record.status = .cancelada
        record.updatedAt = Date()
        save()
        cancelNotifications(for: record)
    }

    // MARK: - Alertas

    /// Programa las alertas de una actividad, cancelando antes lo que hubiera.
    public func syncNotifications(for record: ActivityRecord, soundID: String? = nil) {
        let snapshot = record.toSnapshot()
        let sound = soundID ?? record.soundID
        Task { await NotificationScheduler().sync(snapshot, soundID: sound) }
    }

    public func cancelNotifications(for record: ActivityRecord) {
        NotificationScheduler().cancel(activityID: record.id)
    }

    /// Recalcula los estados que dependen del reloj y limpia alertas huérfanas.
    /// Se llama al abrir la app y al volver del segundo plano.
    public func refreshTimeDependentStates(now: Date = Date()) {
        let records = all()
        for record in records where record.status.isOpen {
            let snapshot = record.toSnapshot()
            if snapshot.hasClosed(at: now, calendar: calendar) {
                markUnconfirmed(record)
            } else if snapshot.startDate.timeIntervalSince(now) < 3600, record.status == .programada {
                record.status = .proxima
            }
        }
        save()
        let live = Set(records.map(\.id))
        Task { await NotificationScheduler().reconcile(with: live) }
    }

    public func find(id: UUID) -> ActivityRecord? {
        all().first { $0.id == id }
    }

    public func delete(_ record: ActivityRecord) {
        cancelNotifications(for: record)
        context.delete(record)
        save()
    }

    /// Borrado total. Solo desde Perfil, con doble confirmación.
    public func deleteAll() {
        let all = (try? context.fetch(FetchDescriptor<ActivityRecord>())) ?? []
        for record in all {
            cancelNotifications(for: record)
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
