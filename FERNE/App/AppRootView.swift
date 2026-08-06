import SwiftUI

/// Raíz de navegación. Fase 0 entrega el esqueleto: Splash → contenido con 4 pestañas.
/// El onboarding real (pantallas 02 y 03) llega en la Fase 2.
struct AppRootView: View {
    @Environment(ThemeController.self) private var theme
    @State private var isShowingSplash = !UITestConfiguration.skipsSplash

    var body: some View {
        ZStack {
            MainTabView()
                .opacity(isShowingSplash ? 0 : 1)

            if isShowingSplash {
                SplashView { isShowingSplash = false }
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .ferneTheme(theme.theme)
        .animation(FerneMotion.ease, value: isShowingSplash)
        .forcedReduceMotionForScreenshots()
        .accessibilityIdentifier("ferne.root")
    }
}

private extension View {
    /// Permite capturar la variante Reduce Motion sin tocar el ajuste del sistema.
    ///
    /// **Solo sobrescribe cuando el UI test lo pide explícitamente.** Si se aplicara
    /// siempre, un build normal pisaría el ajuste real de iOS con `false` y FERNÉ
    /// dejaría de respetar Reduce Motion para quien lo tiene activado.
    ///
    /// No sustituye a verificar el ajuste real del sistema: ver `docs/VISUAL_QA_MATRIX.md`.
    @ViewBuilder
    func forcedReduceMotionForScreenshots() -> some View {
        if UITestConfiguration.forcesReduceMotion {
            environment(\.accessibilityReduceMotion, true)
        } else {
            self
        }
    }
}

#Preview("Raíz · mañana") {
    AppRootView().environment(ThemeController.preview(.manana))
}
