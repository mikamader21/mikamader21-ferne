import Foundation

/// Representación **pura** (sin SwiftData, sin SwiftUI) de una actividad.
///
/// Existe para que el dominio y el motor de score sean testeables sin contenedor
/// de persistencia y sin simulador. En la Fase 1, el `@Model Activity` de SwiftData
/// se proyectará a este tipo mediante `toSnapshot()`.
///
/// Campos según MASTER_SPEC §7.1.
public struct ActivitySnapshot: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var category: ActivityCategory
    public var startDate: Date
    public var endDate: Date?
    public var allDay: Bool
    public var recurrenceRule: RecurrenceRule?
    public var reminderOffsets: [TimeInterval]
    public var soundID: String?
    public var priority: Priority
    public var requiresConfirmation: Bool
    public var status: ActivityStatus
    public var completedAt: Date?
    public var rescheduledFrom: Date?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        category: ActivityCategory,
        startDate: Date,
        endDate: Date? = nil,
        allDay: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        reminderOffsets: [TimeInterval] = [],
        soundID: String? = nil,
        priority: Priority = .normal,
        requiresConfirmation: Bool = false,
        status: ActivityStatus = .programada,
        completedAt: Date? = nil,
        rescheduledFrom: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.allDay = allDay
        self.recurrenceRule = recurrenceRule
        self.reminderOffsets = reminderOffsets
        self.soundID = soundID
        self.priority = priority
        self.requiresConfirmation = requiresConfirmation
        self.status = status
        self.completedAt = completedAt
        self.rescheduledFrom = rescheduledFrom
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var isEvaluable: Bool {
        status.isEvaluable
    }

    public var isCompleted: Bool {
        status.countsAsCompleted
    }

    public var wasRescheduled: Bool {
        status == .reprogramada || rescheduledFrom != nil
    }

    /// Fin de la ventana de cumplimiento. Si no hay `endDate`, se usa la duración
    /// sugerida de la categoría: sin ventana no se sabe cuándo preguntar el resultado.
    public func windowEnd(calendar: Calendar) -> Date {
        if let endDate {
            return endDate
        }
        return calendar.date(
            byAdding: .minute,
            value: category.suggestedDurationMinutes,
            to: startDate
        ) ?? startDate
    }

    /// `true` si su ventana ya terminó respecto a `now`.
    public func hasClosed(at now: Date, calendar: Calendar) -> Bool {
        windowEnd(calendar: calendar) <= now
    }

    /// `true` si está ocurriendo ahora mismo.
    public func isRunning(at now: Date, calendar: Calendar) -> Bool {
        startDate <= now && now < windowEnd(calendar: calendar)
    }

    /// Puntos que aporta, **solo** si su ventana cerró.
    ///
    /// Una actividad futura no vale cero: no vale nada todavía. Es la diferencia
    /// entre "no lo hizo" y "aún no le tocaba".
    public func contribution(at now: Date, calendar: Calendar) -> Double? {
        guard hasClosed(at: now, calendar: calendar) else { return nil }
        return status.earnedFraction
    }

    /// Día natural al que pertenece la actividad, con calendario explícito.
    /// Resuelve el caso "cruce de medianoche" de §9.4: la actividad pertenece al día de su `startDate`.
    public func day(in calendar: Calendar) -> Date {
        calendar.startOfDay(for: startDate)
    }
}
