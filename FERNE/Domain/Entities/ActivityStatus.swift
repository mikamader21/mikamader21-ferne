import Foundation

/// Estados de una actividad (MASTER_SPEC §7.1).
public enum ActivityStatus: String, CaseIterable, Codable, Sendable {
    case programada
    case completada
    case pendiente
    case reprogramada
    case omitida
    case cancelada

    /// Solo las evaluables entran al denominador del score diario (§9.1).
    /// Las canceladas se excluyen; las reprogramadas se informan aparte y **no** son fracaso.
    public var isEvaluable: Bool {
        switch self {
        case .programada, .completada, .pendiente, .omitida: true
        case .cancelada, .reprogramada: false
        }
    }

    public var countsAsCompleted: Bool { self == .completada }

    /// Texto amable. Prohibido el vocabulario punitivo (§9.3).
    public var displayName: String {
        switch self {
        case .programada:   "Programada"
        case .completada:   "Completada"
        case .pendiente:    "Pendiente"
        case .reprogramada: "Reprogramada"
        case .omitida:      "Sin marcar"
        case .cancelada:    "Cancelada"
        }
    }
}
