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
        ScoreEngine(calendar: calendar).weeklyScore(weekContaining: now, activities: snapshots, now: now)
    }

    private var todayScore: DailyScore {
        ScoreEngine(calendar: calendar).dailyScore(for: now, activities: snapshots, now: now)
    }

    /// Actividades de hoy, en orden, para la línea temporal.
    private var todayTimeline: [ActivitySnapshot] {
        let target = calendar.startOfDay(for: now)
        return snapshots
            .filter { $0.day(in: calendar) == target }
            .sorted { $0.startDate < $1.startDate }
    }

    private var weekSnapshots: [ActivitySnapshot] {
        let start = ScoreEngine(calendar: calendar).startOfWeek(for: now)
        guard let end = calendar.date(byAdding: .day, value: 7, to: start) else { return [] }
        return snapshots.filter { $0.day(in: calendar) >= start && $0.day(in: calendar) < end }
    }

    /// Magenta sobre cielo claro, blanco luminoso sobre cielo nocturno.
    private var titleColor: Color {
        themeController.theme.hasDarkAtmosphere ? FerneColor.luminousWhite : FerneColor.brandMagenta
    }

    var body: some View {
        FerneScreen(sceneIntensity: 0.7) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    AtmosphericText {
                        Text("Así va tu semana, \(preferences.preferredName)")
                            .font(FerneFont.greeting)
                            .foregroundStyle(titleColor)
                    }
                    .padding(.top, 150)

                    scoreCard

                    if !todayTimeline.isEmpty {
                        timelineCard
                    }

                    if weekly.hasData {
                        CountersCard(snapshots: weekSnapshots)
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

                Group {
                    if weekly.hasData {
                        Label(weekly.state.message, systemImage: "chart.line.uptrend.xyaxis")
                            .font(FerneFont.cardTitle)
                            .foregroundStyle(FerneColor.brandMagenta)
                    } else {
                        Text("Tu progreso aparecerá cuando confirmes tus primeras actividades.")
                            .font(FerneFont.body)
                            .foregroundStyle(FerneColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                // Texto visible convertido en elemento accesible: es el contenido
                // que confirma que Progreso terminó de cargar, con datos o sin ellos.
                .accessibilityElement()
                .accessibilityLabel(weekly.hasData ? weekly.state
                    .message : "Tu progreso aparecerá cuando confirmes tus primeras actividades.")
                .accessibilityIdentifier("progress.summary")

                if todayScore.hasData || todayScore.openCount > 0 {
                    VStack(spacing: 2) {
                        if todayScore.hasData {
                            Text("\(todayScore.displayPercentage) % hasta ahora")
                                .font(FerneFont.cardTitle)
                                .foregroundStyle(FerneColor.textPrimary)
                        }
                        Text(todayScore.confirmedSummary)
                            .font(FerneFont.meta)
                            .foregroundStyle(FerneColor.textSecondary)
                        if let remaining = todayScore.remainingSummary {
                            Text(remaining)
                                .font(FerneFont.meta)
                                .foregroundStyle(FerneColor.textMuted)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Contadores

    // MARK: - Línea temporal

    /// El score debe poder explicarse: aquí se ve, actividad por actividad, de dónde
    /// sale cada punto. Un número sin desglose es una caja negra.
    private var timelineCard: some View {
        FerneCard {
            VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                Text("TU DÍA, PASO A PASO")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textMuted)

                ForEach(todayTimeline) { activity in
                    TimelineRow(activity: activity, now: now, calendar: calendar)
                    if activity.id != todayTimeline.last?.id {
                        Divider().overlay(FerneColor.cardBorder)
                    }
                }
            }
        }
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
