import SwiftData
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

/// Raíz de navegación: Splash → (onboarding la primera vez) → contenido.
struct AppRootView: View {
    @Environment(ThemeController.self) private var theme
    @Environment(UserPreferences.self) private var preferences

    @State private var isShowingSplash = !UITestConfiguration.skipsSplash
    @State private var hasFinishedOnboarding = false

    var body: some View {
        ZStack {
            content
                .opacity(isShowingSplash ? 0 : 1)

            if isShowingSplash {
                SplashView {
                    withAnimation(FerneMotion.ease) { isShowingSplash = false }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .ferneTheme(theme.theme)
        .animation(FerneMotion.ease, value: isShowingSplash)
        .forcedReduceMotionForScreenshots()
        .accessibilityIdentifier("ferne.root")
        .onAppear { hasFinishedOnboarding = preferences.hasCompletedOnboarding }
        // Si Fer viaja o cambia la hora del iPhone, la escena se recalcula sola.
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
            theme.timeZoneDidChange()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            theme.timeZoneDidChange()
        }
    }

    @ViewBuilder
    private var content: some View {
        if preferences.hasCompletedOnboarding || hasFinishedOnboarding {
            MainTabView()
                .transition(.opacity)
        } else {
            OnboardingFlowView(preferences: preferences) {
                // `expressive` es una duración en segundos, no una Animation:
                // hay que construir la curva con ella.
                withAnimation(.easeInOut(duration: FerneMotion.expressive)) { hasFinishedOnboarding = true }
            }
            .transition(.opacity)
        }
    }
}

private extension View {
    /// Permite capturar la variante Reduce Motion sin tocar el ajuste del sistema.
    ///
    /// **Solo sobrescribe cuando el UI test lo pide explícitamente.** Si se aplicara
    /// siempre, un build normal pisaría el ajuste real de iOS y FERNÉ dejaría de
    /// respetar Reduce Motion para quien lo tiene activado.
    ///
    /// Se escribe `\.ferneReduceMotionOverride`, no `\.accessibilityReduceMotion`:
    /// esta última es de solo lectura y no admite `.environment(_:_:)`.
    @ViewBuilder
    func forcedReduceMotionForScreenshots() -> some View {
        if UITestConfiguration.forcesReduceMotion {
            environment(\.ferneReduceMotionOverride, true)
        } else {
            self
        }
    }
}

#Preview("Raíz · mañana") {
    AppRootView()
        .environment(ThemeController.preview(.manana))
        .environment(UserPreferences())
        .modelContainer(for: ActivityRecord.self, inMemory: true)
}
