import SwiftUI

@main
struct FerneApp: App {
    @State private var theme = ThemeController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(theme)
                .ferneTheme(theme.theme)
                .tint(FerneColor.accentPrimary)
                // FERNÉ es una app luminosa: no hay variante oscura del sistema,
                // el "modo noche" lo gobierna DayPhase, no el ajuste de iOS (§4.5).
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { _, newPhase in
            // La franja horaria puede haber cambiado mientras la app estaba en segundo plano.
            if newPhase == .active { theme.refresh() }
        }
    }
}
