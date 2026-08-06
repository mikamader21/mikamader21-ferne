import SwiftUI

/// Barra inferior principal (MASTER_SPEC §5): Inicio · Progreso · Destellos · Perfil.
/// Agenda y Rutinas se alcanzan desde Inicio, no desde la barra.
struct MainTabView: View {
    @Environment(ThemeController.self) private var theme
    @State private var selection: Tab = .inicio

    enum Tab: String, Hashable, CaseIterable {
        case inicio
        case progreso
        case destellos
        case perfil

        var title: String {
            switch self {
            case .inicio:    "Inicio"
            case .progreso:  "Progreso"
            case .destellos: "Destellos"
            case .perfil:    "Perfil"
            }
        }

        var symbol: String {
            switch self {
            case .inicio:    "sun.horizon.fill"
            case .progreso:  "chart.line.uptrend.xyaxis"
            case .destellos: "sparkles"
            case .perfil:    "person.crop.circle"
            }
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationStack {
                    destination(for: tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbol)
                }
                .tag(tab)
            }
        }
        .ferneTheme(theme.theme)
    }

    @ViewBuilder
    private func destination(for tab: Tab) -> some View {
        switch tab {
        case .inicio:    HomeView()
        case .progreso:  ProgressView()
        case .destellos: SparksView()
        case .perfil:    ProfileView()
        }
    }
}

#Preview("Pestañas · noche") {
    MainTabView().environment(ThemeController.preview(.noche))
}
