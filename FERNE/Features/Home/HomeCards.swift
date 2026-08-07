import SwiftUI

/// Tarjeta "Mi día": anillo de progreso y recuento de confirmaciones.
struct MyDayCard: View {
    let score: DailyScore

    var body: some View {
        FerneCard(padding: FerneSpacing.sm) {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text("MI DÍA")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)

                FerneProgressRing(
                    value: score.hasData ? score.rawPercentage / 100 : 0,
                    label: "Mi día",
                    diameter: 108
                )
                .frame(maxWidth: .infinity)

                Text(score.confirmedSummary)
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

/// Tarjeta "Lo que sigue": próxima actividad con su cuenta regresiva.
struct NextUpCard: View {
    let activity: ActivitySnapshot?
    let now: Date

    var body: some View {
        FerneCard(padding: FerneSpacing.sm) {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text("LO QUE SIGUE")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)

                if let next = activity {
                    Label {
                        Text(next.title)
                            .font(FerneFont.sectionTitle)
                            .foregroundStyle(FerneColor.textPrimary)
                    } icon: {
                        Image(systemName: next.category.symbolName)
                            .foregroundStyle(FerneColor.categoryTint(next.category))
                    }
                    Text(HomeView.time(next.startDate))
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(FerneColor.brandMagenta)

                    if let countdown = Self.countdown(from: now, to: next.startDate) {
                        Text(countdown)
                            .font(FerneFont.meta)
                            .foregroundStyle(FerneColor.brandMagenta)
                            .padding(.horizontal, FerneSpacing.xs)
                            .padding(.vertical, 5)
                            .background { Capsule().fill(FerneColor.cloudPink) }
                    }
                } else {
                    Text("Nada pendiente ahora mismo ✨")
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension NextUpCard {
    /// "Faltan 35 min". `nil` si queda más de un día o ya pasó.
    static func countdown(from now: Date, to date: Date) -> String? {
        let seconds = date.timeIntervalSince(now)
        guard seconds > 0, seconds < 86400 else { return nil }
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "Faltan \(max(minutes, 1)) min"
        }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "Faltan \(hours) h" : "Faltan \(hours) h \(rest) min"
    }
}

/// Estado vacío con accesos rápidos. Nunca una pantalla en blanco.
struct HomeEmptyState: View {
    let onQuickAdd: (ActivityCategory) -> Void

    var body: some View {
        FerneCard(padding: FerneSpacing.lg) {
            VStack(spacing: FerneSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(FerneColor.accentSecondary)
                Text("Tu día está en blanco")
                    .font(FerneFont.sectionTitle)
                    .foregroundStyle(FerneColor.textPrimary)
                Text("Toca el botón + para agregar tu primera actividad. Empieza por lo que más te importe hoy.")
                    .font(FerneFont.secondary)
                    .foregroundStyle(FerneColor.textSecondary)
                    .multilineTextAlignment(.center)

                Divider().overlay(FerneColor.cardBorder).padding(.vertical, FerneSpacing.xxs)

                Text("O empieza por aquí")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textMuted)

                HStack(spacing: FerneSpacing.xs) {
                    ForEach([ActivityCategory.despertar, .comida, .gym], id: \.self) { category in
                        QuickAddChip(category: category) { onQuickAdd(category) }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
