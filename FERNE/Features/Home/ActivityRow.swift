import SwiftUI

/// Acceso rápido del estado vacío: abre el editor con la categoría ya elegida.
struct QuickAddChip: View {
    let category: ActivityCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: FerneSpacing.xxs) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(FerneColor.categoryTint(category))
                Text(category.displayName)
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: FerneSize.minimumTapTarget + 16)
            .padding(.vertical, FerneSpacing.xs)
            .background {
                RoundedRectangle(cornerRadius: FerneRadius.control, style: .continuous)
                    .fill(FerneColor.surfaceSoft)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Agregar \(category.displayName)")
    }
}

/// Fila de actividad. El estado nunca depende solo del color: hay icono, tachado y texto.
struct ActivityRow: View {
    let activity: ActivitySnapshot
    var isInProgress: Bool = false
    var onToggle: (() -> Void)?

    var body: some View {
        HStack(spacing: FerneSpacing.sm) {
            if isInProgress {
                Capsule()
                    .fill(FerneColor.brandMagenta)
                    .frame(width: 4)
                    .accessibilityHidden(true)
            }

            Image(systemName: activity.category.symbolName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(activity.isCompleted ? .white : FerneColor.categoryTint(activity.category))
                .frame(width: FerneSize.categoryIcon, height: FerneSize.categoryIcon)
                .background {
                    Circle().fill(
                        activity.isCompleted
                            ? FerneColor.categoryTint(activity.category).opacity(0.85)
                            : FerneColor.surfaceSoft
                    )
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(activity.isCompleted ? FerneColor.textTertiary : FerneColor.textPrimary)
                    .strikethrough(activity.isCompleted, color: FerneColor.textTertiary)
                Text(timeRange)
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textTertiary)
            }

            Spacer(minLength: 0)

            if let onToggle {
                Button(action: onToggle) {
                    FerneCheckmark(isChecked: activity.isCompleted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(activity.isCompleted ? "Marcar como pendiente" : "Completar")
            } else {
                FerneCheckmark(isChecked: activity.isCompleted)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("activity.row.\(activity.category.rawValue)")
        .accessibilityLabel("\(activity.title), \(activity.category.displayName), \(timeRange)")
        .accessibilityValue(activity.status.displayName)
    }

    private var timeRange: String {
        guard let end = activity.endDate else { return HomeView.time(activity.startDate) }
        return "\(HomeView.time(activity.startDate)) - \(HomeView.time(end))"
    }
}

#Preview("Inicio · vacío") {
    NavigationStack { HomeView() }
        .environment(ThemeController.preview(.manana))
        .environment(UserPreferences())
        .modelContainer(for: ActivityRecord.self, inMemory: true)
}
