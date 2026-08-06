import Foundation

/// Guardia de lenguaje (MASTER_SPEC §9.3).
///
/// FERNÉ orienta, no castiga. Este tipo existe para que la prohibición sea
/// **verificable por pruebas** y no solo una nota en la documentación.
public enum ScoreLanguage {
    /// Vocabulario prohibido en cualquier texto visible al usuario.
    public static let forbiddenTerms: [String] = [
        "fracaso", "fracasaste", "fracasada",
        "mala", "malo", "mal día",
        "insuficiente", "deficiente",
        "perezosa", "perezoso", "floja", "flojo",
        "incumpliste", "fallaste", "fallo", "culpa",
        "vergüenza", "castigo", "penalización"
    ]

    /// `true` si el texto contiene vocabulario punitivo.
    public static func containsForbiddenTerm(_ text: String) -> Bool {
        firstForbiddenTerm(in: text) != nil
    }

    public static func firstForbiddenTerm(in text: String) -> String? {
        let normalized = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_ES"))
        return forbiddenTerms.first { term in
            let normalizedTerm = term.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_ES"))
            return normalized.contains(normalizedTerm)
        }
    }
}

/// Formato obligatorio de una recomendación (§9.3):
/// 1. Observación verificable · 2. Explicación breve · 3. Cambio pequeño · 4. Acción opcional.
public struct Recommendation: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    /// 1. Qué se observó, con datos reales.
    public let observation: String
    /// 2. Por qué importa.
    public let explanation: String
    /// 3. Qué cambio pequeño se propone.
    public let suggestedChange: String
    /// 4. Etiqueta de la acción opcional. `nil` ⇒ recomendación solo informativa.
    public let actionLabel: String?

    public init(
        id: UUID = UUID(),
        observation: String,
        explanation: String,
        suggestedChange: String,
        actionLabel: String? = nil
    ) {
        self.id = id
        self.observation = observation
        self.explanation = explanation
        self.suggestedChange = suggestedChange
        self.actionLabel = actionLabel
    }

    /// Todo el texto visible, para auditar el lenguaje de una sola pasada.
    public var allVisibleText: String {
        [observation, explanation, suggestedChange, actionLabel].compactMap { $0 }.joined(separator: " ")
    }

    public var usesApprovedLanguage: Bool {
        !ScoreLanguage.containsForbiddenTerm(allVisibleText)
    }

    /// Ejemplo canónico de la especificación.
    public static let example = Recommendation(
        observation: "Esta semana comenzaste mejor la lectura entre las 19:00 y las 20:00.",
        explanation: "Es el rango donde más veces terminaste la sesión completa.",
        suggestedChange: "Reservar ese horario los días de lectura.",
        actionLabel: "Reservar 19:00"
    )
}
