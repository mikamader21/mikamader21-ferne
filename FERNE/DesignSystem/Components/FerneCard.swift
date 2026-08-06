import SwiftUI

/// Tarjeta base (MASTER_SPEC §4.4): radio 20–24 pt, blanco cálido o translúcido,
/// borde sutil y sombra rosada ligera.
public struct FerneCard<Content: View>: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let padding: CGFloat
    private let content: Content

    public init(padding: CGFloat = FerneSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                    .fill(backgroundColor)
            }
            .overlay {
                RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                    .strokeBorder(FerneColor.cardBorder, lineWidth: 1)
            }
            .shadow(color: FerneColor.cardShadow, radius: FerneShadow.cardRadius, y: FerneShadow.cardY)
    }

    private var backgroundColor: Color {
        // En noche la tarjeta es translúcida; si el usuario reduce transparencia, se vuelve sólida.
        guard theme.phase == .noche, !reduceTransparency else { return FerneColor.warmWhite }
        return theme.cardBackground
    }
}

#Preview("Tarjeta · mañana") {
    ZStack {
        SkyScene(intensity: 0.6)
        FerneCard {
            Text("Lo que sigue")
                .font(FerneFont.cardTitle)
                .foregroundStyle(FerneColor.textPrimary)
        }
        .padding()
    }
    .ferneTheme(.manana)
}
