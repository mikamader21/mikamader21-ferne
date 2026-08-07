import SwiftData
import SwiftUI
import UserNotifications

@main
struct FerneApp: App {
    @State private var theme = ThemeController()
    @State private var preferences = UserPreferences()
    @Environment(\.scenePhase) private var scenePhase

    /// Contenedor de SwiftData. En producción arranca **vacío**; solo los UI tests
    /// reciben un contenedor en memoria con datos deterministas.
    private let container: ModelContainer
    private let responder: NotificationResponder

    init() {
        let container = ModelContainerFactory.make()
        self.container = container
        responder = NotificationResponder(container: container)
        let center = UNUserNotificationCenter.current()
        center.delegate = responder
        NotificationCategories.registerAll(on: center)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(theme)
                .environment(preferences)
                .ferneTheme(theme.theme)
                .tint(FerneColor.accentPrimary)
                // FERNÉ es una app luminosa: el "modo noche" lo gobierna DayPhase,
                // no el ajuste de apariencia de iOS (§4.5).
                .preferredColorScheme(.light)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            // La franja horaria pudo cambiar mientras la app estaba en segundo plano.
            if newPhase == .active {
                theme.refresh()
            }
        }
    }
}
