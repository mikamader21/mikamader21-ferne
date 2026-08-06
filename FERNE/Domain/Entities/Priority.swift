import Foundation

/// Importancia de una actividad. Afecta al orden en Inicio y a la prominencia de la alerta.
public enum Priority: Int, CaseIterable, Codable, Sendable, Comparable {
    case suave = 0
    case normal = 1
    case importante = 2
    case esencial = 3

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var displayName: String {
        switch self {
        case .suave: "Suave"
        case .normal: "Normal"
        case .importante: "Importante"
        case .esencial: "Esencial"
        }
    }

    /// Solo despertar y dormir usan alarma prominente (AlarmKit) — MASTER_SPEC §8.2.
    public var deservesProminentAlarm: Bool {
        self == .esencial
    }
}
