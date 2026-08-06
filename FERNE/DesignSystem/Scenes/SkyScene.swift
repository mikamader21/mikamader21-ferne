import SwiftUI

/// Fondo cinematográfico de FERNÉ.
///
/// **Nunca** debe sustituirse por un color plano (MASTER_SPEC §4.5, §14.3).
/// Con `Reduce Motion` la escena conserva cielo, astro, halo y nubes: solo se
/// detiene el movimiento. Con `Reduce Transparency` se opacan las capas suaves.
public struct SkyScene: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Intensidad de la escena: 1.0 en Splash e Inicio, menor detrás de listas densas.
    private let intensity: Double
    @State private var animate = false

    public init(intensity: Double = 1.0) {
        self.intensity = min(max(intensity, 0), 1)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.skyGradient
                    .ignoresSafeArea()

                if theme.starOpacity > 0 {
                    StarField(
                        palette: theme.particlePalette,
                        opacity: theme.starOpacity * intensity,
                        animate: animate && !reduceMotion
                    )
                }

                CelestialBodyView(theme: theme, animate: animate && !reduceMotion)
                    .frame(width: geometry.size.width * 0.42)
                    .position(
                        x: geometry.size.width * 0.72,
                        y: geometry.size.height * (theme.phase == .tarde ? 0.14 : 0.20)
                    )
                    .opacity(intensity)

                CloudLayer(
                    color: theme.cloudColor.opacity(reduceTransparency ? 1 : 0.9),
                    animate: animate && !reduceMotion
                )
                .opacity(intensity)

                SparkleLayer(
                    color: theme.particleColor,
                    count: FerneMotion.particleCount,
                    animate: animate && !reduceMotion
                )
                .opacity(intensity * (reduceTransparency ? 0.5 : 1))
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
        .accessibilityElement()
        .accessibilityLabel(theme.phase.accessibilityDescription)
        .accessibilityHidden(false)
    }
}

/// Sol o luna con halo. Movimiento lento y vertical, casi imperceptible (§4.6).
struct CelestialBodyView: View {
    let theme: FerneTheme
    let animate: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.celestialGlow)
                .scaleEffect(2.4)
                .blur(radius: 12)

            Circle()
                .fill(theme.celestialCore)
                .shadow(color: theme.celestialHalo.opacity(0.6), radius: 30)

            if theme.celestialBody == .moon {
                // Cráteres suaves: la luna no es un círculo plano.
                Circle()
                    .fill(theme.celestialHalo.opacity(0.18))
                    .frame(width: 22, height: 22)
                    .offset(x: -14, y: -10)
                Circle()
                    .fill(theme.celestialHalo.opacity(0.14))
                    .frame(width: 13, height: 13)
                    .offset(x: 16, y: 12)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .offset(y: animate ? -10 : 10)
        .animation(
            animate ? .easeInOut(duration: FerneMotion.celestialCycle).repeatForever(autoreverses: true) : nil,
            value: animate
        )
    }
}

/// Nubes de deriva casi imperceptible.
struct CloudLayer: View {
    let color: Color
    let animate: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                cloud(width: geometry.size.width * 0.62)
                    .position(x: geometry.size.width * 0.30, y: geometry.size.height * 0.26)
                    .offset(x: animate ? 18 : -18)
                cloud(width: geometry.size.width * 0.45)
                    .position(x: geometry.size.width * 0.78, y: geometry.size.height * 0.36)
                    .offset(x: animate ? -14 : 14)
            }
            .animation(
                animate ? .easeInOut(duration: FerneMotion.cloudDrift).repeatForever(autoreverses: true) : nil,
                value: animate
            )
        }
    }

    private func cloud(width: CGFloat) -> some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: width * 0.22)
            .blur(radius: 18)
    }
}

/// Estrellas de la escena nocturna. Alternan blanco luminoso y dorado.
struct StarField: View {
    let palette: [Color]
    let opacity: Double
    let animate: Bool

    /// Posiciones deterministas: la escena debe verse igual en cada captura de QA visual.
    private static let positions: [(x: Double, y: Double, size: Double)] = [
        (0.12, 0.10, 2.4), (0.28, 0.06, 1.8), (0.44, 0.15, 2.0), (0.58, 0.05, 1.6),
        (0.86, 0.12, 2.2), (0.20, 0.22, 1.7), (0.66, 0.24, 2.1), (0.92, 0.28, 1.5),
        (0.08, 0.34, 1.9), (0.38, 0.31, 1.6), (0.74, 0.36, 2.3), (0.52, 0.40, 1.4)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(Self.positions.enumerated()), id: \.offset) { index, star in
                    Circle()
                        .fill(palette[index % max(palette.count, 1)])
                        .frame(width: star.size, height: star.size)
                        .position(x: geometry.size.width * star.x, y: geometry.size.height * star.y)
                        .opacity(animate ? 0.35 : 1)
                        .animation(
                            animate
                                ? .easeInOut(duration: FerneMotion.sparkleCycle + Double(index) * 0.17)
                                    .repeatForever(autoreverses: true)
                                : nil,
                            value: animate
                        )
                }
            }
            .opacity(opacity)
        }
    }
}

/// Partículas/destellos de baja densidad (§4.6).
struct SparkleLayer: View {
    let color: Color
    let count: Int
    let animate: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let seed = Double(index)
                    Circle()
                        .fill(color)
                        .frame(width: 3, height: 3)
                        .blur(radius: 0.6)
                        .position(
                            x: geometry.size.width * ((seed * 0.137).truncatingRemainder(dividingBy: 1)),
                            y: geometry.size.height * (0.12 + (seed * 0.219).truncatingRemainder(dividingBy: 0.7))
                        )
                        .opacity(animate ? 0.15 : 0.7)
                        .animation(
                            animate
                                ? .easeInOut(duration: FerneMotion.sparkleCycle + seed * 0.23)
                                    .repeatForever(autoreverses: true)
                                : nil,
                            value: animate
                        )
                }
            }
        }
    }
}

#Preview("Mañana") { SkyScene().ferneTheme(.manana) }
#Preview("Tarde")  { SkyScene().ferneTheme(.tarde) }
#Preview("Noche")  { SkyScene().ferneTheme(.noche) }
