import Foundation

/// Franja horaria que gobierna el tema visual y el saludo (MASTER_SPEC §4.5).
///
/// Tipo puro: define **cuándo** aplica cada tema. El *cómo* se ve vive en
/// `DesignSystem/Theme/FerneTheme.swift`. Así la regla horaria es testeable sin UI.
public enum DayPhase: String, CaseIterable, Codable, Sendable {
    /// 05:00 – 11:59 · amanecer rosa/melocotón, sol emergente.
    case manana
    /// 12:00 – 17:59 · cielo brillante y coral, sol alto.
    case tarde
    /// 18:00 – 04:59 · cielo ciruela, luna con halo, estrellas. Nunca negro puro.
    case noche

    /// Determina la franja a partir de una fecha y un calendario explícito.
    ///
    /// La noche empieza a las **18:00** en punto. Difiere de MASTER_SPEC §4.5, que
    /// decía 19:00: decisión de producto tomada el 6 de agosto de 2026 al ver que a
    /// las 18:00 la luz ya no acompaña la escena diurna.
    public static func from(_ date: Date, calendar: Calendar = .ferneDefault) -> DayPhase {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5 ... 11: return .manana
        case 12 ... 17: return .tarde
        default: return .noche // 18…23 y 0…4
        }
    }

    /// Instante exacto en que empieza la siguiente franja, para poder programar el
    /// cambio de escena sin sondear el reloj cada segundo.
    public static func nextTransition(after date: Date, calendar: Calendar) -> Date? {
        let boundaries = [5, 12, 18]
        let hour = calendar.component(.hour, from: date)
        if let next = boundaries.first(where: { $0 > hour }) {
            return calendar.date(bySettingHour: next, minute: 0, second: 0, of: date)
        }
        // Pasadas las 18:00, la próxima frontera son las 05:00 del día siguiente.
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
        return calendar.date(bySettingHour: 5, minute: 0, second: 0, of: tomorrow)
    }

    /// Saludo aprobado. Los emojis forman parte de la especificación (§4.5).
    public func greeting(name: String) -> String {
        switch self {
        case .manana: "Buenos días, \(name) ✨"
        case .tarde: "Buenas tardes, \(name)"
        // Sin emoji de luna: la escena ya muestra una. Repetirla en el texto era
        // redundante. El detalle discreto lo aporta un símbolo en la vista.
        case .noche: "Buenas noches, \(name)"
        }
    }

    /// El astro protagonista de la escena. Nunca hay escena sin astro.
    public var celestialBody: CelestialBody {
        switch self {
        case .manana, .tarde: .sun
        case .noche: .moon
        }
    }

    public var accessibilityDescription: String {
        switch self {
        case .manana: "Amanecer con sol emergente y nubes"
        case .tarde: "Cielo de tarde con sol alto y destellos"
        case .noche: "Cielo nocturno ciruela con luna y estrellas"
        }
    }
}

/// Astro de la escena de fondo.
public enum CelestialBody: String, Codable, Sendable {
    case sun
    case moon
}
