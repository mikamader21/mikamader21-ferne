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

/// Bloque de texto colocado **sobre la escena atmosférica**.
///
/// Resuelve el problema de contraste: en mañana y tarde el cielo tiene zonas muy
/// claras (sol, nubes) donde cualquier color pierde fuerza. Debajo del texto se
/// coloca un velo del blanco cálido de la paleta —nunca una caja negra— y el
/// texto va en ciruela oscuro. De noche, el cielo ya es oscuro y el texto va claro
/// sin velo.
public struct AtmosphericText<Content: View>: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @ViewBuilder let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, FerneSpacing.xs)
            .padding(.vertical, FerneSpacing.xs)
            .background {
                if theme.needsTextScrim {
                    RoundedRectangle(cornerRadius: FerneRadius.control, style: .continuous)
                        .fill(reduceTransparency ? AnyShapeStyle(FerneColor.warmWhite) : AnyShapeStyle(FerneColor.textScrim))
                        .blur(radius: reduceTransparency ? 0 : 10)
                }
            }
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
                .foregroundStyle(theme.textOnAtmosphere)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(FerneFont.secondary)
                    .foregroundStyle(theme.secondaryOnAtmosphere)
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
