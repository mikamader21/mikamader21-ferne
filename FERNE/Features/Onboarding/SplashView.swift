import SwiftUI

/// Pantalla 01 — Splash cinematográfico (MASTER_SPEC §6.01).
///
/// Escena de ~2 s con la franja horaria real: amanecer con sol, tarde luminosa o
/// noche con luna y estrellas. **Nunca** logo sobre fondo plano.
///
/// Con Reduce Motion la escena se conserva íntegra —cielo, astro, halo, nubes,
/// estrellas— y solo se detiene el movimiento.
struct SplashView: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride

    let onFinish: () -> Void

    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    @State private var sceneRevealed = false
    @State private var logoVisible = false
    @State private var taglineVisible = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            SkyScene(intensity: 1.0)
                .scaleEffect(sceneRevealed || reduceMotion ? 1.0 : 1.12)
                .opacity(sceneRevealed || reduceMotion ? 1 : 0)

            // Halo suave detrás del logotipo, para que el texto respire sobre la escena.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [FerneColor.luminousWhite.opacity(0.55), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 440)
                .scaleEffect(glowPulse && !reduceMotion ? 1.08 : 0.96)
                .opacity(logoVisible ? 1 : 0)
                .blur(radius: 8)

            VStack(spacing: FerneSpacing.sm) {
                Spacer()

                Text("FERNÉ")
                    .font(FerneFont.display)
                    .kerning(8)
                    // Magenta sobre el amanecer, blanco luminoso sobre la noche.
                    .foregroundStyle(theme.hasDarkAtmosphere ? FerneColor.luminousWhite : FerneColor.brandMagenta)
                    .shadow(
                        color: theme.hasDarkAtmosphere
                            ? FerneColor.deepPlum.opacity(0.6)
                            : FerneColor.luminousWhite.opacity(0.9),
                        radius: 14
                    )
                    .opacity(logoVisible ? 1 : 0)
                    .offset(y: logoVisible || reduceMotion ? 0 : 18)

                Text("Tu día, a tu ritmo")
                    .font(FerneFont.secondary)
                    .kerning(1.5)
                    .foregroundStyle(theme.secondaryOnAtmosphere)
                    .opacity(taglineVisible ? 1 : 0)
                    .offset(y: taglineVisible || reduceMotion ? 0 : 10)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, FerneSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("FERNÉ. Tu día, a tu ritmo.")
        .accessibilityIdentifier("screen.splash")
        .task { await run() }
        // Tocar la pantalla salta la escena: útil con VoiceOver y en uso diario.
        .onTapGesture { onFinish() }
    }

    private func run() async {
        guard !reduceMotion else {
            // Escena completa, sin coreografía.
            sceneRevealed = true
            logoVisible = true
            taglineVisible = true
            try? await Task.sleep(for: .seconds(1.0))
            onFinish()
            return
        }

        withAnimation(.easeOut(duration: 0.9)) { sceneRevealed = true }
        try? await Task.sleep(for: .seconds(0.35))
        withAnimation(.easeOut(duration: 0.55)) { logoVisible = true }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { glowPulse = true }
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.easeOut(duration: 0.5)) { taglineVisible = true }
        try? await Task.sleep(for: .seconds(1.1))
        onFinish()
    }
}

#Preview("Splash · mañana") { SplashView {}.ferneTheme(.manana) }
#Preview("Splash · tarde") { SplashView {}.ferneTheme(.tarde) }
#Preview("Splash · noche") { SplashView {}.ferneTheme(.noche) }
