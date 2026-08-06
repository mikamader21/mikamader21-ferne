import SwiftUI

/// Tema visual derivado de la franja horaria (MASTER_SPEC §4.5).
///
/// Un `DayPhase` (dominio puro) entra; un conjunto de colores y parámetros de
/// escena sale. Las vistas nunca calculan la hora ni eligen colores por su cuenta.
public struct FerneTheme: Equatable, Sendable {
    public let phase: DayPhase
    /// Colores del cielo, de arriba abajo.
    public let skyColors: [Color]
    public let celestialCore: Color
    public let celestialHalo: Color
    public let cloudColor: Color
    public let particleColor: Color
    public let titleColor: Color
    public let bodyColor: Color
    public let cardBackground: Color
    /// Opacidad de las estrellas. 0 en día.
    public let starOpacity: Double

    public var celestialBody: CelestialBody {
        phase.celestialBody
    }

    public var skyGradient: LinearGradient {
        LinearGradient(colors: skyColors, startPoint: .top, endPoint: .bottom)
    }

    /// Halo radial del sol o de la luna. Nunca hay astro sin halo.
    public var celestialGlow: RadialGradient {
        RadialGradient(
            colors: [celestialCore, celestialHalo.opacity(0.55), celestialHalo.opacity(0)],
            center: .center,
            startRadius: 4,
            endRadius: 150
        )
    }

    /// Colores de las partículas. De noche se alternan blancas y doradas.
    public var particlePalette: [Color] {
        phase == .noche ? [FerneColor.luminousWhite, FerneColor.sunGold] : [particleColor]
    }

    // MARK: - Variantes aprobadas

    /// 05:00–11:59 · amanecer.
    ///
    /// Derivado de `01-splash-approved.png`: rosa de amanecer, melocotón, y los fríos
    /// atmosféricos (cian y lavanda) presentes en la referencia, siempre en los bordes y
    /// con opacidad baja para que no compitan con la luz cálida central.
    public static let manana = FerneTheme(
        phase: .manana,
        skyColors: [
            FerneColor.dawnPink.opacity(0.75),
            FerneColor.cloudPink,
            FerneColor.skyCyan.opacity(0.18), // atmosférico: cielo alto
            FerneColor.peachCoral.opacity(0.55),
            FerneColor.ivoryRose,
        ],
        celestialCore: FerneColor.sunGold,
        celestialHalo: FerneColor.peachCoral,
        cloudColor: FerneColor.warmWhite.opacity(0.85),
        particleColor: FerneColor.sunGold.opacity(0.6),
        titleColor: FerneColor.deepPlum,
        bodyColor: FerneColor.secondaryPlum,
        cardBackground: FerneColor.warmWhite,
        starOpacity: 0
    )

    /// 12:00–18:59 · mayor luminosidad, coral y melocotón, cian más suave, sol alto.
    public static let tarde = FerneTheme(
        phase: .tarde,
        skyColors: [
            FerneColor.skyCyan.opacity(0.12), // atmosférico: más suave que en la mañana
            FerneColor.dawnPeach.opacity(0.5),
            FerneColor.peachCoral.opacity(0.45),
            FerneColor.cloudPink.opacity(0.7),
            FerneColor.ivoryRose,
        ],
        celestialCore: FerneColor.sunGold,
        celestialHalo: FerneColor.sunGold,
        cloudColor: FerneColor.warmWhite.opacity(0.9),
        particleColor: FerneColor.sunGold.opacity(0.7),
        titleColor: FerneColor.deepPlum,
        bodyColor: FerneColor.secondaryPlum,
        cardBackground: FerneColor.warmWhite,
        starOpacity: 0
    )

    /// 19:00–04:59 · noche.
    ///
    /// **No existe una referencia nocturna.** Esta variante se deriva del mismo universo
    /// visual de las tres referencias aprobadas (decisión D-024): se conservan los rosados,
    /// la lavanda y el índigo del Splash, y se bajan de luminosidad hacia el ciruela.
    ///
    /// La luna es **cálida**, no blanca fría. Las nubes son rosadas oscuras, no grises.
    /// Las partículas mezclan blanco y dorado.
    ///
    /// Prohibido: negro puro, azul corporativo, cielo frío genérico, estética espacial,
    /// neón, y perder los tonos rosados.
    public static let noche = FerneTheme(
        phase: .noche,
        skyColors: [
            FerneColor.deepPlum, // ciruela profundo, nunca negro
            FerneColor.secondaryPlum,
            FerneColor.softIndigo.opacity(0.45), // atmosférico: índigo suave
            FerneColor.nightPlum, // ciruela nocturno de transición
            FerneColor.lavender.opacity(0.7), // atmosférico: lavanda
            FerneColor.softPink.opacity(0.55), // el rosado nunca desaparece
        ],
        celestialCore: FerneColor.luminousWhite,
        celestialHalo: FerneColor.sunGold, // halo cálido: la luna de FERNÉ no es fría
        cloudColor: FerneColor.softPink.opacity(0.32), // nubes rosadas oscuras, no grises
        particleColor: FerneColor.luminousWhite,
        titleColor: FerneColor.warmWhite,
        bodyColor: FerneColor.cloudPink,
        cardBackground: FerneColor.warmWhite.opacity(0.14),
        starOpacity: 0.9
    )

    public static func theme(for phase: DayPhase) -> FerneTheme {
        switch phase {
        case .manana: manana
        case .tarde: tarde
        case .noche: noche
        }
    }
}

// MARK: - Environment

private struct FerneThemeKey: EnvironmentKey {
    static let defaultValue: FerneTheme = .manana
}

public extension EnvironmentValues {
    var ferneTheme: FerneTheme {
        get { self[FerneThemeKey.self] }
        set { self[FerneThemeKey.self] = newValue }
    }
}

public extension View {
    func ferneTheme(_ theme: FerneTheme) -> some View {
        environment(\.ferneTheme, theme)
    }

    func ferneTheme(phase: DayPhase) -> some View {
        environment(\.ferneTheme, .theme(for: phase))
    }
}
