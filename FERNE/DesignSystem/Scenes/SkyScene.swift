import SwiftUI

/// Fondo cinematográfico de FERNÉ.
///
/// **Nunca** debe sustituirse por un color plano (MASTER_SPEC §4.5, §14.3).
/// Con `Reduce Motion` la escena conserva cielo, astro, halo y nubes: solo se
/// detiene el movimiento. Con `Reduce Transparency` se opacan las capas suaves.
public struct SkyScene: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    /// Reduce Motion efectivo: el override de los UI tests si existe, si no el ajuste del sistema.
    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

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
                    // La luna se dibuja un 28 % menor que el sol: a igual tamaño
                    // dominaba la composición y competía con el texto.
                    .frame(width: geometry.size.width * (theme.celestialBody == .moon ? 0.30 : 0.42))
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
            // Resplandor exterior amplio: es lo que da sensación de luz real, en
            // lugar de un círculo pegado encima del fondo.
            Circle()
                .fill(theme.celestialGlow)
                .scaleEffect(3.4)
                .blur(radius: 26)

            Circle()
                .fill(theme.celestialGlow)
                .scaleEffect(2.0)
                .blur(radius: 8)

            if theme.celestialBody == .sun {
                // Rayos: 12 destellos, largos y cortos alternados.
                ForEach(0 ..< 12, id: \.self) { index in
                    Capsule()
                        .fill(theme.celestialHalo.opacity(index.isMultiple(of: 2) ? 0.30 : 0.16))
                        .frame(width: 3, height: index.isMultiple(of: 2) ? 46 : 28)
                        .offset(y: -62)
                        .rotationEffect(.degrees(Double(index) * 30))
                        .blur(radius: 1.5)
                }
            }

            Circle()
                .fill(
                    // Degradado en lugar de relleno plano: sin él la luna parece un
                    // disco blanco sobreexpuesto, sin volumen.
                    RadialGradient(
                        colors: [theme.celestialCore, theme.celestialCore.opacity(0.82)],
                        center: UnitPoint(x: 0.38, y: 0.34),
                        startRadius: 2,
                        endRadius: 70
                    )
                )
                .shadow(color: theme.celestialHalo.opacity(0.75), radius: 40)
                .shadow(color: theme.celestialHalo.opacity(0.45), radius: 90)

            if theme.celestialBody == .moon {
                // Cráteres suaves: la luna no es un círculo plano.
                Circle()
                    .fill(theme.celestialHalo.opacity(0.20))
                    .frame(width: 26, height: 26)
                    .offset(x: -16, y: -12)
                    .blur(radius: 1)
                Circle()
                    .fill(theme.celestialHalo.opacity(0.16))
                    .frame(width: 15, height: 15)
                    .offset(x: 18, y: 14)
                    .blur(radius: 1)
                Circle()
                    .fill(theme.celestialHalo.opacity(0.12))
                    .frame(width: 9, height: 9)
                    .offset(x: -6, y: 20)
                    .blur(radius: 1)
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
                cloud(width: geometry.size.width * 0.72, opacity: 0.9)
                    .position(x: geometry.size.width * 0.28, y: geometry.size.height * 0.20)
                    .offset(x: animate ? 22 : -22)
                cloud(width: geometry.size.width * 0.52, opacity: 0.7)
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height * 0.31)
                    .offset(x: animate ? -18 : 18)
                cloud(width: geometry.size.width * 0.44, opacity: 0.5)
                    .position(x: geometry.size.width * 0.45, y: geometry.size.height * 0.40)
                    .offset(x: animate ? 12 : -12)
            }
            .animation(
                animate ? .easeInOut(duration: FerneMotion.cloudDrift).repeatForever(autoreverses: true) : nil,
                value: animate
            )
        }
    }

    /// Una nube es un cuerpo más dos lóbulos: una cápsula sola parece una barra.
    private func cloud(width: CGFloat, opacity: Double) -> some View {
        ZStack {
            Capsule()
                .fill(color.opacity(opacity))
                .frame(width: width, height: width * 0.20)
            Circle()
                .fill(color.opacity(opacity))
                .frame(width: width * 0.34, height: width * 0.34)
                .offset(x: -width * 0.16, y: -width * 0.07)
            Circle()
                .fill(color.opacity(opacity * 0.9))
                .frame(width: width * 0.26, height: width * 0.26)
                .offset(x: width * 0.18, y: -width * 0.05)
        }
        .blur(radius: 20)
    }
}

/// Estrellas de la escena nocturna. Alternan blanco luminoso y dorado.
struct StarField: View {
    let palette: [Color]
    let opacity: Double
    let animate: Bool

    /// Posición y tamaño de una estrella, en fracción del lienzo.
    private struct Star {
        let x: Double
        let y: Double
        let size: Double
    }

    /// Posiciones deterministas: la escena debe verse igual en cada captura de QA visual.
    private static let positions: [Star] = [
        Star(x: 0.12, y: 0.10, size: 2.4), Star(x: 0.28, y: 0.06, size: 1.8),
        Star(x: 0.44, y: 0.15, size: 2.0), Star(x: 0.58, y: 0.05, size: 1.6),
        Star(x: 0.86, y: 0.12, size: 2.2), Star(x: 0.20, y: 0.22, size: 1.7),
        Star(x: 0.66, y: 0.24, size: 2.1), Star(x: 0.92, y: 0.28, size: 1.5),
        Star(x: 0.08, y: 0.34, size: 1.9), Star(x: 0.38, y: 0.31, size: 1.6),
        Star(x: 0.74, y: 0.36, size: 2.3), Star(x: 0.52, y: 0.40, size: 1.4)
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
                ForEach(0 ..< count, id: \.self) { index in
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
#Preview("Tarde") { SkyScene().ferneTheme(.tarde) }
#Preview("Noche") { SkyScene().ferneTheme(.noche) }
