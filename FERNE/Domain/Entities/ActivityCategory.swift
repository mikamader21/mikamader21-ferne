import Foundation

/// Categorías de actividad definidas en MASTER_SPEC §7.1.
/// El `rawValue` es estable y persistente: **nunca** renombrar sin una migración.
public enum ActivityCategory: String, CaseIterable, Codable, Sendable {
    case despertar
    case comida
    case gym
    case trabajo
    case live
    case lectura
    case pago
    case rutina
    case evento
    case nota
    case dormir
    case personal

    /// Nombre visible en español. Nunca hardcodear cadenas en las vistas.
    public var displayName: String {
        switch self {
        case .despertar: "Despertar"
        case .comida: "Comida"
        case .gym: "Gym"
        case .trabajo: "Trabajo"
        case .live: "TikTok Live"
        case .lectura: "Lectura"
        case .pago: "Pago"
        case .rutina: "Rutina"
        case .evento: "Evento"
        case .nota: "Nota"
        case .dormir: "Dormir"
        case .personal: "Personal"
        }
    }

    /// SF Symbol asociado. Ver `docs/DESIGN_SYSTEM.md`.
    public var symbolName: String {
        switch self {
        case .despertar: "sunrise.fill"
        case .comida: "fork.knife"
        case .gym: "figure.run"
        case .trabajo: "laptopcomputer"
        case .live: "video.fill"
        case .lectura: "book.fill"
        case .pago: "creditcard.fill"
        case .rutina: "list.bullet.rectangle"
        case .evento: "calendar"
        case .nota: "note.text"
        case .dormir: "moon.stars.fill"
        case .personal: "heart.fill"
        }
    }

    /// Categorías que cuentan como "horario importante" para la constancia semanal (§9.2).
    public var isKeySchedule: Bool {
        switch self {
        case .despertar, .comida, .dormir: true
        default: false
        }
    }

    /// Compromisos con meta semanal (§9.2).
    public var isWeeklyCommitment: Bool {
        switch self {
        case .gym, .live, .lectura: true
        default: false
        }
    }

    /// Duración sugerida en minutos cuando Fer no indica una.
    ///
    /// Hace falta para saber **cuándo termina la ventana** de una actividad y poder
    /// preguntar por su resultado. Es una sugerencia: siempre es editable.
    public var suggestedDurationMinutes: Int {
        switch self {
        case .despertar: 15
        case .comida: 45
        case .gym: 60
        case .trabajo: 90
        case .live: 60
        case .lectura: 30
        case .pago: 10
        case .rutina: 30
        case .evento: 60
        case .nota: 10
        case .dormir: 30
        case .personal: 45
        }
    }

    /// Verbo con el que se confirma el cumplimiento. Hablar en concreto ("Ya comí")
    /// es más cálido y más claro que un "Completar" genérico.
    public var completionVerb: String {
        switch self {
        case .despertar: "Ya me levanté"
        case .comida: "Ya comí"
        case .gym: "Entrenamiento cumplido"
        case .lectura: "Terminé mi lectura"
        case .live: "Hice el live"
        case .pago: "Recibo pagado"
        case .dormir: "Ya estoy en la cama"
        case .trabajo: "Tarea terminada"
        case .rutina, .evento, .nota, .personal: "Actividad cumplida"
        }
    }
}
