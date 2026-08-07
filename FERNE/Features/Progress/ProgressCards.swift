import SwiftUI

/// Los seis recuentos de la semana, con los estados nuevos.
struct CountersCard: View {
    let snapshots: [ActivitySnapshot]

    private func count(of status: ActivityStatus) -> Int {
        snapshots.filter { $0.status == status }.count
    }

    /// Lo que aún espera respuesta de Fer.
    private var openCount: Int {
        snapshots.filter { $0.status == .programada || $0.status == .proxima || $0.status == .enCurso }.count
    }

    var body: some View {
        FerneCard {
            VStack(spacing: FerneSpacing.sm) {
                HStack(spacing: FerneSpacing.sm) {
                    counter(
                        value: count(of: .completada),
                        label: "COMPLETADAS",
                        symbol: "checkmark.circle.fill",
                        tint: FerneColor.positive
                    )
                    counter(
                        value: count(of: .parcial),
                        label: "PARCIALES",
                        symbol: "circle.lefthalf.filled",
                        tint: FerneColor.sunGold
                    )
                    counter(
                        value: openCount,
                        label: "PENDIENTES",
                        symbol: "clock.fill",
                        tint: FerneColor.attention
                    )
                }
                HStack(spacing: FerneSpacing.sm) {
                    counter(
                        value: count(of: .reprogramada),
                        label: "REPROGRAMADAS",
                        symbol: "arrow.triangle.2.circlepath",
                        tint: FerneColor.accentSecondary
                    )
                    counter(
                        value: count(of: .sinConfirmar),
                        label: "SIN CONFIRMAR",
                        symbol: "questionmark.circle",
                        tint: FerneColor.textMuted
                    )
                    counter(
                        value: count(of: .omitida),
                        label: "NO ESTA VEZ",
                        symbol: "minus.circle",
                        tint: FerneColor.textMuted
                    )
                }
            }
        }
    }

    private func counter(value: Int, label: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: FerneSpacing.xxs) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background { Circle().fill(tint.opacity(0.18)) }
            Text("\(value)")
                .font(FerneFont.sectionTitle)
                .foregroundStyle(FerneColor.textPrimary)
            Text(label)
                .font(FerneFont.labelCaps)
                .kerning(0.8)
                .foregroundStyle(FerneColor.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct InsightCard: View {
    let symbol: String
    let tint: Color
    let caption: String
    let text: String

    var body: some View {
        FerneCard {
            HStack(alignment: .top, spacing: FerneSpacing.sm) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background { Circle().fill(tint.opacity(0.20)) }
                VStack(alignment: .leading, spacing: 2) {
                    Text(caption)
                        .font(FerneFont.labelCaps)
                        .kerning(1.0)
                        .foregroundStyle(FerneColor.textTertiary)
                    Text(text)
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textPrimary)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Progreso · sin datos") {
    NavigationStack { ProgressView() }
        .environment(ThemeController.preview(.tarde))
        .environment(UserPreferences())
        .modelContainer(for: ActivityRecord.self, inMemory: true)
}

/// Una fila de la línea temporal: hora, icono, actividad, estado y puntos.
struct TimelineRow: View {
    let activity: ActivitySnapshot
    let now: Date
    let calendar: Calendar

    var body: some View {
        HStack(spacing: FerneSpacing.sm) {
            Text(HomeView.time(activity.startDate))
                .font(FerneFont.meta)
                .foregroundStyle(FerneColor.textMuted)
                .frame(width: 46, alignment: .leading)

            Image(systemName: activity.category.symbolName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(FerneColor.categoryTint(activity.category))
                .frame(width: 28, height: 28)
                .background { Circle().fill(FerneColor.surfaceSoft) }

            VStack(alignment: .leading, spacing: 1) {
                Text(activity.title)
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(FerneColor.textPrimary)
                Text(stateLabel)
                    .font(FerneFont.meta)
                    .foregroundStyle(stateTint)
            }

            Spacer(minLength: 0)

            Text(pointsLabel)
                .font(FerneFont.meta)
                .foregroundStyle(FerneColor.textSecondary)

            Image(systemName: activity.status.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(stateTint)
        }
        .frame(minHeight: FerneSize.minimumTapTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(HomeView.time(activity.startDate)), \(activity.title), \(stateLabel), \(pointsLabel)")
    }

    /// Estado ajustado al reloj: lo que aún no venció se anuncia como próximo.
    private var stateLabel: String {
        if activity.status.isOpen, !activity.hasClosed(at: now, calendar: calendar) {
            return activity.isRunning(at: now, calendar: calendar) ? "En curso" : "Próximo"
        }
        return activity.status.displayName
    }

    private var stateTint: Color {
        switch activity.status {
        case .completada: FerneColor.positive
        case .parcial: FerneColor.sunGold
        case .omitida: FerneColor.textMuted
        case .enCurso: FerneColor.brandMagenta
        case .reprogramada: FerneColor.accentSecondary
        case .sinConfirmar: FerneColor.attention
        case .programada, .proxima, .cancelada: FerneColor.textMuted
        }
    }

    /// Puntos obtenidos. `—` mientras la ventana siga abierta: todavía no valen nada.
    private var pointsLabel: String {
        guard let fraction = activity.contribution(at: now, calendar: calendar) else { return "—" }
        return fraction == 1 ? "1 pt" : (fraction == 0.5 ? "½ pt" : "0 pt")
    }
}
