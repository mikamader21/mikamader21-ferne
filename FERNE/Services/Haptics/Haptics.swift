import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Haptics con intención, no en cada toque (MASTER_SPEC §4.6).
///
/// Reglas: se permite en confirmaciones, completar, alarma y celebraciones.
/// Prohibido en scroll, aparición de vistas o cada pulsación de lista.
@MainActor
public final class Haptics {
    public static let shared = Haptics()

    /// Preferencia del usuario (Ajustes → Sonidos y haptics).
    @AppStorage("ferne.haptics.enabled") private var isEnabled = true

    private init() {}

    public enum Tap {
        case soft
        case light
        case medium
    }

    public func tap(_ tap: Tap) {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let style: UIImpactFeedbackGenerator.FeedbackStyle = switch tap {
        case .soft: .soft
        case .light: .light
        case .medium: .medium
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        #endif
    }

    /// Al completar una actividad.
    public func success() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    /// Solo para errores técnicos reales. Nunca para "no completaste algo".
    public func warning() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
