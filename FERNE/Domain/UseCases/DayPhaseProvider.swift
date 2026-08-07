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

    /// Usa `autoupdatingCurrent` a propósito: si Fer viaja o cambia la zona horaria
    /// del iPhone, la escena debe seguir su hora **local**, no una fija.
    public init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    public var now: Date {
        Date()
    }

    public var currentPhase: DayPhase {
        DayPhase.from(now, calendar: calendar)
    }

    /// Cuándo cambia la escena, para programarlo sin sondear el reloj.
    public var nextTransition: Date? {
        DayPhase.nextTransition(after: now, calendar: calendar)
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
