import Foundation
import SwiftData

/// Actividad persistida (MASTER_SPEC §7.1).
///
/// Los enums se guardan por su `rawValue` en columnas `String`: ese valor es contrato
/// con los datos ya escritos en el dispositivo y renombrarlo los rompería.
/// El dominio nunca ve este tipo; se proyecta a `ActivitySnapshot`.
@Model
public final class ActivityRecord {
    public var id: UUID = UUID()
    public var title: String = ""
    public var notes: String?
    public var categoryRaw: String = ActivityCategory.evento.rawValue
    public var startDate: Date = Date()
    public var endDate: Date?
    public var allDay: Bool = false
    public var reminderOffsets: [Double] = []
    public var soundID: String?
    public var priorityRaw: Int = Priority.normal.rawValue
    public var requiresConfirmation: Bool = false
    public var statusRaw: String = ActivityStatus.programada.rawValue
    public var completedAt: Date?
    public var rescheduledFrom: Date?
    /// Cuántas veces se movió. La primera no penaliza; las siguientes se muestran
    /// como señal de mejora, nunca como reproche.
    public var rescheduleCount: Int = 0
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    // Recurrencia desglosada en columnas simples en lugar de un blob codificado:
    // así puede consultarse y migrarse sin decodificar nada.
    public var recurrenceFrequencyRaw: String?
    public var recurrenceInterval: Int = 1
    public var recurrenceWeekdays: [Int] = []
    public var recurrenceEndDate: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        category: ActivityCategory,
        startDate: Date,
        endDate: Date? = nil,
        allDay: Bool = false,
        recurrence: RecurrenceRule? = nil,
        reminderOffsets: [TimeInterval] = [],
        soundID: String? = nil,
        priority: Priority = .normal,
        requiresConfirmation: Bool = false,
        status: ActivityStatus = .programada
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        categoryRaw = category.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.allDay = allDay
        self.reminderOffsets = reminderOffsets
        self.soundID = soundID
        priorityRaw = priority.rawValue
        self.requiresConfirmation = requiresConfirmation
        statusRaw = status.rawValue
        createdAt = Date()
        updatedAt = Date()
        applyRecurrence(recurrence)
    }

    // MARK: - Accesores tipados

    public var category: ActivityCategory {
        get { ActivityCategory(rawValue: categoryRaw) ?? .evento }
        set { categoryRaw = newValue.rawValue }
    }

    public var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .normal }
        set { priorityRaw = newValue.rawValue }
    }

    public var status: ActivityStatus {
        // `fromStored` reconoce el `pendiente` de la versión anterior.
        get { ActivityStatus.fromStored(statusRaw) }
        set { statusRaw = newValue.rawValue }
    }

    public var recurrence: RecurrenceRule? {
        guard let raw = recurrenceFrequencyRaw,
              let frequency = RecurrenceRule.Frequency(rawValue: raw)
        else { return nil }
        return RecurrenceRule(
            frequency: frequency,
            interval: recurrenceInterval,
            weekdays: Set(recurrenceWeekdays),
            endDate: recurrenceEndDate
        )
    }

    public func applyRecurrence(_ rule: RecurrenceRule?) {
        recurrenceFrequencyRaw = rule?.frequency.rawValue
        recurrenceInterval = rule?.interval ?? 1
        recurrenceWeekdays = rule.map { Array($0.weekdays).sorted() } ?? []
        recurrenceEndDate = rule?.endDate
    }

    /// Proyección hacia el dominio puro. Una sola dirección.
    public func toSnapshot() -> ActivitySnapshot {
        ActivitySnapshot(
            id: id,
            title: title,
            notes: notes,
            category: category,
            startDate: startDate,
            endDate: endDate,
            allDay: allDay,
            recurrenceRule: recurrence,
            reminderOffsets: reminderOffsets,
            soundID: soundID,
            priority: priority,
            requiresConfirmation: requiresConfirmation,
            status: status,
            completedAt: completedAt,
            rescheduledFrom: rescheduledFrom,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
