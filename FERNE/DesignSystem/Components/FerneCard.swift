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
                    .fill(.ultraThinMaterial)
                    .overlay {
                        // Un velo cálido sobre el material: sin él, el vidrio de iOS
                        // tira a gris y la tarjeta pierde la temperatura de FERNÉ.
                        RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                            .fill(backgroundColor)
                    }
            }
            .overlay {
                // Borde luminoso: blanco arriba, rosa abajo. Da el canto de vidrio.
                RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                FerneColor.luminousWhite.opacity(0.85),
                                FerneColor.softPink.opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: FerneColor.cardShadow, radius: FerneShadow.cardRadius, y: FerneShadow.cardY)
            .shadow(color: FerneColor.deepPlum.opacity(0.05), radius: 3, y: 1)
    }

    /// Velo sobre el material. Con `Reduce Transparency` pasa a sólido: el ajuste
    /// existe precisamente para que no haya nada translúcido.
    private var backgroundColor: Color {
        if reduceTransparency {
            return theme.phase == .noche ? FerneColor.secondaryPlum : FerneColor.warmWhite
        }
        return theme.phase == .noche
            ? FerneColor.warmWhite.opacity(0.10)
            : FerneColor.warmWhite.opacity(0.55)
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
