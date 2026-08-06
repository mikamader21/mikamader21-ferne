import Foundation

/// Franja horaria que gobierna el tema visual y el saludo (MASTER_SPEC §4.5).
///
/// Tipo puro: define **cuándo** aplica cada tema. El *cómo* se ve vive en
/// `DesignSystem/Theme/FerneTheme.swift`. Así la regla horaria es testeable sin UI.
public enum DayPhase: String, CaseIterable, Codable, Sendable {
    /// 05:00 – 11:59 · amanecer rosa/melocotón, sol emergente.
    case manana
    /// 12:00 – 18:59 · cielo brillante y coral, sol alto.
    case tarde
    /// 19:00 – 04:59 · cielo ciruela, luna con halo, estrellas. Nunca negro puro.
    case noche

    /// Determina la franja a partir de una fecha y un calendario explícito.
    public static func from(_ date: Date, calendar: Calendar = .ferneDefault) -> DayPhase {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5...11:  return .manana
        case 12...18: return .tarde
        default:      return .noche   // 19…23 y 0…4
        }
    }

    /// Saludo aprobado. Los emojis forman parte de la especificación (§4.5).
    public func greeting(name: String) -> String {
        switch self {
        case .manana: "Buenos días, \(name) ✨"
        case .tarde:  "Buenas tardes, \(name)"
        case .noche:  "Buenas noches, \(name) 🌙"
        }
    }

    /// El astro protagonista de la escena. Nunca hay escena sin astro.
    public var celestialBody: CelestialBody {
        switch self {
        case .manana, .tarde: .sun
        case .noche:          .moon
        }
    }

    public var accessibilityDescription: String {
        switch self {
        case .manana: "Amanecer con sol emergente y nubes"
        case .tarde:  "Cielo de tarde con sol alto y destellos"
        case .noche:  "Cielo nocturno ciruela con luna y estrellas"
        }
    }
}

/// Astro de la escena de fondo.
public enum CelestialBody: String, Codable, Sendable {
    case sun
    case moon
}
