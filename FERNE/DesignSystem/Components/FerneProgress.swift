import SwiftUI

/// Círculo de progreso animado (Inicio · "Mi día", Progreso, Resumen).
public struct FerneProgressRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 0…1.
    private let value: Double
    private let label: String
    private let diameter: CGFloat

    public init(value: Double, label: String, diameter: CGFloat = 120) {
        self.value = min(max(value, 0), 1)
        self.label = label
        self.diameter = diameter
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(FerneColor.cloudPink, lineWidth: 12)

            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    AngularGradient(
                        colors: [FerneColor.fernePink, FerneColor.peachCoral, FerneColor.sunGold],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : FerneMotion.progress, value: value)

            VStack(spacing: 2) {
                Text("\(Int((value * 100).rounded()))%")
                    .font(FerneFont.scoreNumber)
                    .foregroundStyle(FerneColor.textPrimary)
                Text(label)
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textTertiary)
            }
        }
        .frame(width: diameter, height: diameter)
        // Sin esto, VoiceOver leería tres elementos sueltos sin sentido.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int((value * 100).rounded())) por ciento")
    }
}

/// Barra de progreso animada.
public struct FerneProgressBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let value: Double
    private let accessibilityLabel: String

    public init(value: Double, accessibilityLabel: String) {
        self.value = min(max(value, 0), 1)
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(FerneColor.cloudPink)
                Capsule()
                    .fill(FerneColor.primaryButtonGradient)
                    .frame(width: geometry.size.width * value)
                    .animation(reduceMotion ? nil : FerneMotion.progress, value: value)
            }
        }
        .frame(height: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(Int((value * 100).rounded())) por ciento")
    }
}

/// Check elástico al completar (§4.6).
public struct FerneCheckmark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let isChecked: Bool

    public init(isChecked: Bool) {
        self.isChecked = isChecked
    }

    public var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isChecked ? FerneColor.successSoft : FerneColor.accentSecondary, lineWidth: 2)
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(FerneColor.successSoft)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
        }
        .frame(width: 28, height: 28)
        // El área táctil sigue siendo 44×44 aunque el dibujo mida 28.
        .frame(width: FerneSize.minimumTapTarget, height: FerneSize.minimumTapTarget)
        .contentShape(Rectangle())
        .animation(reduceMotion ? nil : FerneMotion.elasticCheck, value: isChecked)
    }
}

#Preview("Progreso") {
    VStack(spacing: FerneSpacing.lg) {
        FerneProgressRing(value: 0.66, label: "Mi día")
        FerneProgressBar(value: 0.4, accessibilityLabel: "Constancia semanal").padding(.horizontal)
        HStack { FerneCheckmark(isChecked: true); FerneCheckmark(isChecked: false) }
    }
    .padding()
    .background(FerneColor.background)
}
