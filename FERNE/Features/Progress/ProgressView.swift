import SwiftData
import SwiftUI

/// Pantalla 36 — Mi progreso (MASTER_SPEC §6.36).
///
/// Sin actividades evaluables el score es **—**, nunca 0 %. Un día sin datos no es
/// un incumplimiento, y las recomendaciones necesitan datos para existir (§9.3).
struct ProgressView: View {
    @Environment(ThemeController.self) private var themeController
    @Environment(UserPreferences.self) private var preferences

    @Query(sort: \ActivityRecord.startDate, order: .forward)
    private var allActivities: [ActivityRecord]

    @State private var ringValue: Double = 0

    private var calendar: Calendar {
        .ferneDefault
    }

    private var now: Date {
        themeController.referenceDate
    }

    private var snapshots: [ActivitySnapshot] {
        allActivities.map { $0.toSnapshot() }
    }

    private var weekly: WeeklyScore {
        ScoreEngine(calendar: calendar).weeklyScore(weekContaining: now, activities: snapshots)
    }

    private var todayScore: DailyScore {
        ScoreEngine(calendar: calendar).dailyScore(for: now, activities: snapshots)
    }

    private var weekSnapshots: [ActivitySnapshot] {
        let start = ScoreEngine(calendar: calendar).startOfWeek(for: now)
        guard let end = calendar.date(byAdding: .day, value: 7, to: start) else { return [] }
        return snapshots.filter { $0.day(in: calendar) >= start && $0.day(in: calendar) < end }
    }

    var body: some View {
        FerneScreen(sceneIntensity: 0.7) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    Text("Así va tu semana, \(preferences.preferredName)")
                        .font(FerneFont.greeting)
                        .foregroundStyle(FerneColor.brandMagenta)
                        .padding(.top, 150)

                    scoreCard

                    if weekly.hasData {
                        countersCard
                        breakdownCard
                        insightsCard
                    }

                    disclaimerCard
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("screen.progress")
        .task { animateRing() }
    }

    // MARK: - Score

    private var scoreCard: some View {
        FerneCard(padding: FerneSpacing.lg) {
            VStack(spacing: FerneSpacing.sm) {
                ZStack {
                    Circle()
                        .stroke(FerneColor.cloudPink, lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: weekly.hasData ? ringValue : 0)
                        .stroke(
                            AngularGradient(
                                colors: [FerneColor.sunGold, FerneColor.fernePink, FerneColor.brandMagenta],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text(weekly.hasData ? "\(weekly.displayScore)" : "—")
                            .font(FerneFont.scoreNumber)
                            .foregroundStyle(FerneColor.brandMagenta)
                        Text("PUNTOS")
                            .font(FerneFont.labelCaps)
                            .kerning(1.6)
                            .foregroundStyle(FerneColor.textTertiary)
                    }
                }
                .frame(width: 168, height: 168)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Constancia semanal")
                .accessibilityValue(weekly.hasData ? "\(weekly.displayScore) puntos" : "Todavía sin datos")

                if weekly.hasData {
                    Label(weekly.state.message, systemImage: "chart.line.uptrend.xyaxis")
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(FerneColor.brandMagenta)
                } else {
                    Text("Tu progreso aparecerá cuando empieces a construir tu día.")
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Contadores

    private var countersCard: some View {
        FerneCard {
            HStack(spacing: FerneSpacing.sm) {
                counter(
                    value: weekSnapshots.filter(\.isCompleted).count,
                    label: "COMPLETADAS",
                    symbol: "checkmark.circle.fill",
                    tint: FerneColor.positive
                )
                counter(
                    value: weekSnapshots.filter { $0.isEvaluable && !$0.isCompleted }.count,
                    label: "PENDIENTES",
                    symbol: "clock.fill",
                    tint: FerneColor.attention
                )
                counter(
                    value: weekSnapshots.filter(\.wasRescheduled).count,
                    label: "REPROGRAMADAS",
                    symbol: "arrow.triangle.2.circlepath",
                    tint: FerneColor.accentSecondary
                )
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

    // MARK: - Desglose

    private var breakdownCard: some View {
        FerneCard {
            VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                Text("CÓMO SE CALCULA")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)

                ForEach(weekly.breakdown) { item in
                    VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
                        HStack {
                            Text(item.label)
                                .font(FerneFont.secondary)
                                .foregroundStyle(FerneColor.textSecondary)
                            Spacer()
                            Text("\(Int(item.value.rounded())) % · peso \(Int(item.weight * 100)) %")
                                .font(FerneFont.meta)
                                .foregroundStyle(FerneColor.textTertiary)
                        }
                        FerneProgressBar(value: item.value / 100, accessibilityLabel: item.label)
                    }
                }

                Divider().overlay(FerneColor.cardBorder)

                HStack {
                    Text("Hoy")
                        .font(FerneFont.secondary)
                        .foregroundStyle(FerneColor.textSecondary)
                    Spacer()
                    Text(todayScore.hasData ? "\(todayScore.displayPercentage) %" : "—")
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(FerneColor.brandMagenta)
                }
            }
        }
    }

    // MARK: - Observaciones

    /// Solo se muestran cuando hay datos que las sostengan. Nada inventado.
    private var insightsCard: some View {
        VStack(spacing: FerneSpacing.sm) {
            if let strength = bestComponent {
                InsightCard(
                    symbol: "star.fill",
                    tint: FerneColor.sunGold,
                    caption: "LO ESTÁS HACIENDO MUY BIEN EN:",
                    text: strength
                )
            }
            if let opportunity = weakestComponent {
                InsightCard(
                    symbol: "moon.fill",
                    tint: FerneColor.accentSecondary,
                    caption: "PODEMOS MEJORAR:",
                    text: opportunity
                )
            }
        }
    }

    /// Componente con mejor cumplimiento entre los que realmente tienen actividades.
    private var bestComponent: String? {
        measuredComponents.max { $0.value < $1.value }.map(\.label)
    }

    private var weakestComponent: String? {
        let measured = measuredComponents
        guard measured.count > 1 else { return nil }
        guard let worst = measured.min(by: { $0.value < $1.value }), worst.value < 100 else { return nil }
        return worst.label
    }

    /// Un componente sin actividades vale 100 por convención (§9.2). Incluirlo aquí
    /// haría que FERNÉ felicitara a Fer por algo que nunca programó.
    private var measuredComponents: [WeeklyScore.Component] {
        let hasRoutines = weekSnapshots.contains { $0.category == .rutina }
        let hasKey = weekSnapshots.contains(where: \.category.isKeySchedule)
        let hasCommitments = weekSnapshots.contains(where: \.category.isWeeklyCommitment)
        return weekly.breakdown.filter { component in
            switch component.label {
            case "Cumplimiento diario": weekly.hasData
            case "Rutinas": hasRoutines
            case "Horarios importantes": hasKey
            case "Compromisos semanales": hasCommitments
            default: false
            }
        }
    }

    private var disclaimerCard: some View {
        FerneCard {
            Text(WeeklyScore.disclaimer)
                .font(FerneFont.secondary)
                .foregroundStyle(FerneColor.textSecondary)
        }
    }

    private func animateRing() {
        let target = weekly.hasData ? weekly.rawScore / 100 : 0
        withAnimation(FerneMotion.progress.delay(0.15)) { ringValue = target }
    }
}

private struct InsightCard: View {
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
