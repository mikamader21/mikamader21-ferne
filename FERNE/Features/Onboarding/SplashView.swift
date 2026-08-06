import SwiftUI

/// Pantalla 01 — Splash cinematográfico (MASTER_SPEC §6.01).
///
/// Variante día: nubes, amanecer, sol, reflejo, partículas, logo y frase.
/// Variante noche: luna, halo, estrellas y cielo ciruela.
/// Duración 2–3 s. **Nunca** logo sobre fondo plano.
///
/// Fase 0 entrega la escena y el ritmo; el pulido cinematográfico final es Fase 7.
struct SplashView: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    /// Reduce Motion efectivo: el override de los UI tests si existe, si no el ajuste del sistema.
    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    let onFinish: () -> Void

    @State private var logoVisible = false
    @State private var taglineVisible = false

    var body: some View {
        ZStack {
            SkyScene(intensity: 1.0)

            VStack(spacing: FerneSpacing.xs) {
                Spacer()

                Text("FERNÉ")
                    .font(FerneFont.display)
                    .kerning(6)
                    .foregroundStyle(theme.titleColor)
                    .opacity(logoVisible ? 1 : 0)
                    .offset(y: logoVisible || reduceMotion ? 0 : 14)

                Text("Tu día, a tu ritmo.")
                    .font(FerneFont.secondary)
                    .foregroundStyle(theme.bodyColor)
                    .opacity(taglineVisible ? 1 : 0)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, FerneSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("FERNÉ. Tu día, a tu ritmo.")
        .accessibilityIdentifier("screen.splash")
        .task { await run() }
        // Con VoiceOver o Reduce Motion, tocar la pantalla salta la escena de inmediato.
        .onTapGesture { onFinish() }
    }

    private func run() async {
        if reduceMotion {
            // Se conserva la escena (nunca un fondo plano) pero sin coreografía.
            logoVisible = true
            taglineVisible = true
            try? await Task.sleep(for: .seconds(1.0))
            onFinish()
            return
        }

        withAnimation(.easeOut(duration: 0.7)) { logoVisible = true }
        try? await Task.sleep(for: .seconds(0.5))
        withAnimation(.easeOut(duration: 0.6)) { taglineVisible = true }
        try? await Task.sleep(for: .seconds(FerneMotion.splash - 0.5))
        onFinish()
    }
}

#Preview("Splash · día") { SplashView {}.ferneTheme(.manana) }
#Preview("Splash · noche") { SplashView {}.ferneTheme(.noche) }
