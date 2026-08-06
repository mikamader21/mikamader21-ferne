import SwiftUI

/// Sistema de movimiento (MASTER_SPEC §4.6).
///
/// Transiciones de UI: 200–450 ms. Escenas de splash: 2–3 s.
/// Todas las duraciones viven aquí para poder auditarlas y para poder
/// neutralizarlas de golpe cuando `Reduce Motion` está activo.
public enum FerneMotion {
    // MARK: - Duraciones (segundos)

    public static let quick: Double = 0.20
    public static let standard: Double = 0.32
    public static let expressive: Double = 0.45
    public static let splash: Double = 2.6

    /// Rango válido para transiciones de interfaz. Fuera de él, es un error de diseño.
    public static let uiRange: ClosedRange<Double> = 0.20 ... 0.45
    /// Rango válido para escenas cinematográficas.
    public static let sceneRange: ClosedRange<Double> = 2.0 ... 3.0

    // MARK: - Curvas

    public static let ease = Animation.easeInOut(duration: standard)
    public static let enter = Animation.easeOut(duration: quick)
    /// Check elástico al completar una actividad (§4.6).
    public static let elasticCheck = Animation.spring(response: 0.38, dampingFraction: 0.58)
    /// Actualización animada de barras y círculos de progreso.
    public static let progress = Animation.easeInOut(duration: expressive)

    // MARK: - Ambiente

    /// Movimiento lento del sol/luna: un ciclo completo muy largo, casi imperceptible.
    public static let celestialCycle: Double = 24
    /// Deriva de nubes.
    public static let cloudDrift: Double = 38
    /// Parpadeo de partículas/estrellas.
    public static let sparkleCycle: Double = 4.5
    /// Densidad baja de partículas: nunca convertir la escena en ruido visual.
    public static let particleCount = 14

    /// Devuelve `nil` (sin animación) si el usuario pidió reducir movimiento.
    public static func respectingReduceMotion(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

// MARK: - Override de Reduce Motion

/// Sobrescritura de Reduce Motion propia de FERNÉ.
///
/// `\.accessibilityReduceMotion` es de **solo lectura**: SwiftUI la expone como
/// `KeyPath`, no como `WritableKeyPath`, así que no puede escribirse con
/// `.environment(_:_:)`. Esta clave es la vía escribible.
///
/// - `nil` (lo normal): manda el ajuste real de iOS.
/// - `true` / `false`: solo lo fijan los UI tests, para que las capturas de la
///   variante Reduce Motion sean deterministas.
private struct FerneReduceMotionOverrideKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

public extension EnvironmentValues {
    /// Sobrescritura opcional de Reduce Motion. Ver `FerneReduceMotionOverrideKey`.
    var ferneReduceMotionOverride: Bool? {
        get { self[FerneReduceMotionOverrideKey.self] }
        set { self[FerneReduceMotionOverrideKey.self] = newValue }
    }
}

/// Modificador que desactiva por completo la animación ambiental cuando corresponde.
public struct AmbientMotion: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    let animation: Animation
    @Binding var isAnimating: Bool

    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    public func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : animation, value: isAnimating)
            .onAppear {
                if !reduceMotion {
                    isAnimating = true
                }
            }
    }
}
