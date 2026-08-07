import SwiftUI

/// Botón principal: degradado rosa-coral, texto blanco (§4.4).
public struct FernePrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    /// Reduce Motion efectivo: el override de los UI tests si existe, si no el ajuste del sistema.
    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FerneFont.button)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: FerneSize.minimumTapTarget)
            .padding(.horizontal, FerneSpacing.lg)
            .background {
                RoundedRectangle(cornerRadius: FerneRadius.control, style: .continuous)
                    .fill(FerneColor.primaryButtonGradient)
            }
            .shadow(color: FerneColor.cardShadow, radius: 12, y: 6)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : FerneMotion.enter, value: configuration.isPressed)
    }
}

/// Botón secundario: blanco cálido con borde rosa (§4.4).
public struct FerneSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    /// Reduce Motion efectivo: el override de los UI tests si existe, si no el ajuste del sistema.
    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FerneFont.button)
            .foregroundStyle(FerneColor.accentPrimary)
            .frame(maxWidth: .infinity, minHeight: FerneSize.minimumTapTarget)
            .padding(.horizontal, FerneSpacing.lg)
            .background {
                RoundedRectangle(cornerRadius: FerneRadius.control, style: .continuous)
                    .fill(FerneColor.warmWhite)
            }
            .overlay {
                RoundedRectangle(cornerRadius: FerneRadius.control, style: .continuous)
                    .strokeBorder(FerneColor.accentSecondary, lineWidth: 1.5)
            }
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : FerneMotion.enter, value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == FernePrimaryButtonStyle {
    static var fernePrimary: FernePrimaryButtonStyle {
        FernePrimaryButtonStyle()
    }
}

public extension ButtonStyle where Self == FerneSecondaryButtonStyle {
    static var ferneSecondary: FerneSecondaryButtonStyle {
        FerneSecondaryButtonStyle()
    }
}

/// FAB `+`: círculo rosa con haptic suave (§4.4).
public struct FerneFloatingActionButton: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride
    /// Reduce Motion efectivo: el override de los UI tests si existe, si no el ajuste del sistema.
    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button {
            Haptics.shared.tap(.soft)
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: FerneSize.fab, height: FerneSize.fab)
                .background {
                    Circle().fill(FerneColor.primaryButtonGradient)
                }
                .shadow(color: FerneColor.cardShadow, radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Agregar")
        .accessibilityHint("Abre el menú para crear una actividad")
        .accessibilityIdentifier("home.fab")
    }
}

#Preview("Botones") {
    ZStack {
        SkyScene(intensity: 0.5)
        VStack(spacing: FerneSpacing.md) {
            Button("Comenzar") {}.buttonStyle(.fernePrimary)
            Button("Configurar después") {}.buttonStyle(.ferneSecondary)
            FerneFloatingActionButton {}
        }
        .padding()
    }
    .ferneTheme(.manana)
}
