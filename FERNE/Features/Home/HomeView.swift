import SwiftData
import SwiftUI

/// Pantalla 04 — Inicio / Hoy (MASTER_SPEC §6.04).
///
/// Lee de SwiftData. En una instalación nueva no hay nada que mostrar y eso está
/// bien: el estado vacío es una pantalla cuidada, no un hueco.
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(ThemeController.self) private var themeController
    @Environment(UserPreferences.self) private var preferences

    @Query(sort: \ActivityRecord.startDate, order: .forward)
    private var allActivities: [ActivityRecord]

    @State private var isShowingAddMenu = false
    @State private var justCompletedID: UUID?

    private var calendar: Calendar {
        .ferneDefault
    }

    private var now: Date {
        themeController.referenceDate
    }

    private var today: [ActivityRecord] {
        ActivityGrouping.onDay(now, from: allActivities, calendar: calendar)
    }

    private var snapshots: [ActivitySnapshot] {
        today.map { $0.toSnapshot() }
    }

    private var dailyScore: DailyScore {
        ScoreEngine(calendar: calendar).dailyScore(for: now, activities: snapshots)
    }

    private var nextActivity: ActivityRecord? {
        ActivityGrouping.next(after: now, from: allActivities)
    }

    var body: some View {
        FerneScreen(sceneIntensity: 1.0) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    header

                    if today.isEmpty {
                        emptyState
                    } else {
                        HStack(alignment: .top, spacing: FerneSpacing.sm) {
                            myDayCard
                            nextUpCard
                        }
                        agendaSection
                    }
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, 110)
            }
            .scrollContentBackground(.hidden)

            floatingButton
        }
        .navigationTitle("")
        .accessibilityIdentifier("screen.home")
        .sheet(isPresented: $isShowingAddMenu) {
            AddActivitySheet()
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
            Text(themeController.greeting(for: preferences.preferredName))
                .font(FerneFont.greeting)
                .foregroundStyle(FerneColor.brandMagenta)
                .shadow(color: FerneColor.luminousWhite.opacity(0.6), radius: 8)

            if preferences.wantsDailyMessage {
                Text(dailyMessage)
                    .font(FerneFont.body)
                    .foregroundStyle(themeController.theme.bodyColor)
            }

            Text(Self.longDate(now))
                .font(FerneFont.meta)
                .kerning(1.1)
                .foregroundStyle(themeController.theme.bodyColor.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 190)
        .accessibilityElement(children: .combine)
    }

    /// Mensaje del día. No es una recomendación calculada: es una frase amable fija
    /// por franja horaria. Las recomendaciones reales necesitan datos (§9.3).
    private var dailyMessage: String {
        switch themeController.phase {
        case .manana: "Hoy tienes un día bonito por construir."
        case .tarde: "Vas a tu ritmo, y eso está bien."
        case .noche: "Un buen descanso también es parte del día."
        }
    }

    // MARK: - Estado vacío

    private var emptyState: some View {
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
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Tarjetas

    private var myDayCard: some View {
        FerneCard(padding: FerneSpacing.sm) {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text("MI DÍA")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)

                FerneProgressRing(
                    value: dailyScore.hasData ? dailyScore.rawPercentage / 100 : 0,
                    label: "Mi día",
                    diameter: 108
                )
                .frame(maxWidth: .infinity)

                Text("\(dailyScore.completedCount) de \(dailyScore.evaluableCount) completadas")
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var nextUpCard: some View {
        FerneCard(padding: FerneSpacing.sm) {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text("LO QUE SIGUE")
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)

                if let next = nextActivity {
                    Label {
                        Text(next.title)
                            .font(FerneFont.sectionTitle)
                            .foregroundStyle(FerneColor.textPrimary)
                    } icon: {
                        Image(systemName: next.category.symbolName)
                            .foregroundStyle(FerneColor.categoryTint(next.category))
                    }
                    Text(Self.time(next.startDate))
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

    private var agendaSection: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
            Text("Agenda de hoy")
                .font(FerneFont.sectionTitle)
                .foregroundStyle(themeController.theme.titleColor)
                .padding(.top, FerneSpacing.xs)

            ForEach(today) { activity in
                FerneCard(padding: FerneSpacing.sm) {
                    ActivityRow(
                        activity: activity.toSnapshot(),
                        isInProgress: Self.isInProgress(activity, now: now)
                    ) {
                        toggle(activity)
                    }
                }
            }
        }
    }

    private var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FerneFloatingActionButton { isShowingAddMenu = true }
                    .padding(.trailing, FerneSpacing.lg)
                    .padding(.bottom, FerneSpacing.lg)
            }
        }
    }

    // MARK: - Acciones

    private func toggle(_ activity: ActivityRecord) {
        let repository = ActivityRepository(context: context)
        if activity.status == .completada {
            repository.uncomplete(activity)
        } else {
            repository.complete(activity)
            Haptics.shared.success()
            justCompletedID = activity.id
        }
    }

    // MARK: - Formato

    private static func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE d 'de' MMMM"
        return formatter.string(from: date).uppercased()
    }

    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// "Faltan 35 min". `nil` si queda más de un día o ya pasó.
    private static func countdown(from now: Date, to date: Date) -> String? {
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

    private static func isInProgress(_ activity: ActivityRecord, now: Date) -> Bool {
        guard activity.status != .completada else { return false }
        guard let end = activity.endDate else { return false }
        return activity.startDate <= now && now < end
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
