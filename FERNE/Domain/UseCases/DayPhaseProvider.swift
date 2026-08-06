import Foundation

/// Fuente de la franja horaria actual, inyectable para pruebas y previews.
///
/// Las vistas **nunca** llaman a `Date()` directamente: piden la franja aquí.
/// Así una preview puede forzar la noche sin cambiar el reloj del dispositivo.
public protocol DayPhaseProviding: Sendable {
    var currentPhase: DayPhase { get }
    var now: Date { get }
}

public struct SystemDayPhaseProvider: DayPhaseProviding {
    public let calendar: Calendar

    public init(calendar: Calendar = .ferneDefault) {
        self.calendar = calendar
    }

    public var now: Date {
        Date()
    }

    public var currentPhase: DayPhase {
        DayPhase.from(now, calendar: calendar)
    }
}

/// Provider fijo para previews, tests y capturas de QA visual (día/noche).
public struct FixedDayPhaseProvider: DayPhaseProviding {
    public let phase: DayPhase
    public let date: Date

    public init(phase: DayPhase, date: Date = Date()) {
        self.phase = phase
        self.date = date
    }

    public var now: Date {
        date
    }

    public var currentPhase: DayPhase {
        phase
    }
}
