import Foundation

/// Ciclo de vida de una actividad.
///
/// FERNÉ **nunca** marca algo como cumplido por su cuenta: el paso de la hora no es
/// una confirmación. Por eso existen `sinConfirmar` (venció y falta respuesta) y
/// `omitida` (Fer dijo que no lo hizo), que son cosas distintas.
public enum ActivityStatus: String, CaseIterable, Codable, Sendable {
    /// Creada, su hora aún queda lejos.
    case programada
    /// Su hora está cerca. Es cuando llega el recordatorio.
    case proxima
    /// Fer pulsó "Empezar". **No suma puntos**: empezar no es cumplir.
    case enCurso
    /// Confirmada como cumplida.
    case completada
    /// Confirmada a medias.
    case parcial
    /// Movida a otra hora.
    case reprogramada
    /// Fer confirmó que no la hizo.
    case omitida
    /// Su ventana terminó y nadie ha dicho qué pasó.
    case sinConfirmar
    /// Anulada antes de empezar.
    case cancelada

    /// Puntos que aporta, de 0 a 1. `nil` = no entra en el cálculo.
    ///
    /// Lo que **no** puntúa, y por qué:
    /// - `programada` / `proxima`: todavía no venció. Contarla como cero sería
    ///   castigar a Fer por algo que aún puede hacer.
    /// - `enCurso`: empezar no es cumplir.
    /// - `reprogramada`: mover algo no es fallar (§9.1).
    /// - `cancelada`: se excluye por especificación.
    /// - `sinConfirmar`: falta la respuesta. Se muestra aparte y se pide confirmar,
    ///   no se asume el fracaso.
    public var earnedFraction: Double? {
        switch self {
        case .completada: 1.0
        case .parcial: 0.5
        case .omitida: 0.0
        case .programada, .proxima, .enCurso, .reprogramada, .sinConfirmar, .cancelada: nil
        }
    }

    /// `true` si aporta al denominador del score.
    public var isEvaluable: Bool {
        earnedFraction != nil
    }

    public var countsAsCompleted: Bool {
        self == .completada
    }

    /// Estados que aún esperan una respuesta de Fer.
    public var isOpen: Bool {
        switch self {
        case .programada, .proxima, .enCurso, .sinConfirmar: true
        case .completada, .parcial, .omitida, .reprogramada, .cancelada: false
        }
    }

    /// Texto amable. Prohibido el vocabulario punitivo (§9.3).
    public var displayName: String {
        switch self {
        case .programada: "Programada"
        case .proxima: "Próxima"
        case .enCurso: "En curso"
        case .completada: "Completada"
        case .parcial: "Parcial"
        case .reprogramada: "Reprogramada"
        case .omitida: "No esta vez"
        case .sinConfirmar: "Sin confirmar"
        case .cancelada: "Cancelada"
        }
    }

    public var symbolName: String {
        switch self {
        case .programada: "circle"
        case .proxima: "clock"
        case .enCurso: "play.circle.fill"
        case .completada: "checkmark.circle.fill"
        case .parcial: "circle.lefthalf.filled"
        case .reprogramada: "arrow.triangle.2.circlepath"
        case .omitida: "minus.circle"
        case .sinConfirmar: "questionmark.circle"
        case .cancelada: "xmark.circle"
        }
    }

    /// Migración de datos antiguos: `pendiente` pasó a llamarse `sinConfirmar`.
    /// Los `rawValue` son contrato, así que el valor viejo se sigue reconociendo.
    public static func fromStored(_ raw: String) -> ActivityStatus {
        if raw == "pendiente" {
            return .sinConfirmar
        }
        return ActivityStatus(rawValue: raw) ?? .programada
    }
}
