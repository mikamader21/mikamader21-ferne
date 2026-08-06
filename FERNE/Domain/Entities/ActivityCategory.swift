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
}
