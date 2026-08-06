import SwiftUI

/// Contenedor estándar de pantalla.
///
/// Garantiza por construcción que **ninguna pantalla queda con fondo plano**:
/// la escena cinematográfica siempre está debajo del contenido (§14.3).
public struct FerneScreen<Content: View>: View {
    @Environment(\.ferneTheme) private var theme

    private let sceneIntensity: Double
    private let content: Content

    public init(sceneIntensity: Double = 0.75, @ViewBuilder content: () -> Content) {
        self.sceneIntensity = sceneIntensity
        self.content = content()
    }

    public var body: some View {
        ZStack {
            SkyScene(intensity: sceneIntensity)
            content
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

/// Estado vacío amable y con ilustración implícita de la escena. Nunca una pantalla en blanco.
public struct FerneEmptyState: View {
    @Environment(\.ferneTheme) private var theme

    private let symbol: String
    private let title: String
    private let message: String?

    public init(symbol: String, title: String, message: String? = nil) {
        self.symbol = symbol
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: FerneSpacing.sm) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(FerneColor.accentSecondary)
            Text(title)
                .font(FerneFont.sectionTitle)
                .foregroundStyle(theme.titleColor)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(FerneFont.secondary)
                    .foregroundStyle(theme.bodyColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(FerneSpacing.lg)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Estado vacío · noche") {
    FerneScreen {
        FerneEmptyState(symbol: "sparkles", title: "Todo está al día ✨")
    }
    .ferneTheme(.noche)
}
