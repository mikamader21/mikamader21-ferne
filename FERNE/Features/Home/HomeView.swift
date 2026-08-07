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

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride

    @State private var isShowingAddMenu = false
    @State private var quickAdd: ActivityCategory?
    @State private var pendingConfirmation: ActivityRecord?
    @State private var appeared = false

    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

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
        ScoreEngine(calendar: calendar).dailyScore(for: now, activities: snapshots, now: now)
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
                        HomeEmptyState { quickAdd = $0 }
                    } else {
                        HStack(alignment: .top, spacing: FerneSpacing.sm) {
                            MyDayCard(score: dailyScore)
                            NextUpCard(activity: nextActivity?.toSnapshot(), now: now)
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
        .sheet(item: $quickAdd) { category in
            NavigationStack {
                ActivityEditorView(category: category) { quickAdd = nil }
            }
        }
        .confirmationDialog(
            pendingConfirmation.map { "¿\($0.category.completionVerb)?" } ?? "",
            isPresented: Binding(
                get: { pendingConfirmation != nil },
                set: {
                    if !$0 {
                        pendingConfirmation = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            if let activity = pendingConfirmation {
                Button("Sí, cumplido") { apply(.completada, to: activity) }
                Button("Parcialmente") { apply(.parcial, to: activity) }
                Button("No lo hice") { apply(.omitida, to: activity) }
                Button("Cancelar", role: .cancel) { pendingConfirmation = nil }
            }
        }
        .task {
            ActivityRepository(context: context).refreshTimeDependentStates(now: now)
            withAnimation(reduceMotion ? .easeOut(duration: FerneMotion.quick) : nil) { appeared = true }
        }
    }

    /// Acciones disponibles sobre una tarjeta.
    @ViewBuilder
    private func actions(for activity: ActivityRecord) -> some View {
        if activity.status.isOpen {
            Button(activity.category.completionVerb, systemImage: "checkmark.circle") {
                apply(.completada, to: activity)
            }
            Button("Parcialmente", systemImage: "circle.lefthalf.filled") {
                apply(.parcial, to: activity)
            }
            if activity.status != .enCurso {
                Button("Empezar", systemImage: "play.circle") {
                    ActivityRepository(context: context).start(activity)
                    Haptics.shared.tap(.light)
                }
            }
            Button("Reprogramar a mañana", systemImage: "arrow.triangle.2.circlepath") {
                reschedule(activity)
            }
            Button("Hoy no", systemImage: "minus.circle", role: .destructive) {
                apply(.omitida, to: activity)
            }
        } else {
            Button("Volver a abrir", systemImage: "arrow.uturn.backward") {
                ActivityRepository(context: context).reopen(activity)
            }
        }
    }

    // MARK: - Cabecera

    private var header: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
            AtmosphericText {
                VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: FerneSpacing.xs) {
                        Text(themeController.greeting(for: preferences.preferredName))
                            .font(FerneFont.greeting)
                            .foregroundStyle(greetingColor)
                        // Detalle discreto en lugar del emoji: la escena ya tiene
                        // su astro, y repetirlo en el texto era redundante.
                        Image(systemName: themeController.phase == .noche ? "sparkle" : "sun.max.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(FerneColor.sunGold)
                            .accessibilityHidden(true)
                    }

                    if preferences.wantsDailyMessage {
                        Text(dailyMessage)
                            .font(FerneFont.body)
                            .foregroundStyle(themeController.theme.textOnAtmosphere)
                    }

                    Text(Self.longDate(now))
                        .font(FerneFont.meta)
                        .kerning(1.1)
                        .foregroundStyle(themeController.theme.secondaryOnAtmosphere)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 190)
        .accessibilityElement(children: .combine)
    }

    /// El saludo va en magenta de marca sobre cielo claro y en blanco luminoso sobre
    /// el cielo nocturno. Nunca al revés: era donde se perdía el contraste.
    private var greetingColor: Color {
        themeController.theme.hasDarkAtmosphere ? FerneColor.luminousWhite : FerneColor.brandMagenta
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

    // MARK: - Tarjetas

    private var agendaSection: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
            Text("Agenda de hoy")
                .font(FerneFont.sectionTitle)
                .foregroundStyle(themeController.theme.textOnAtmosphere)
                .padding(.top, FerneSpacing.xs)

            ForEach(Array(today.enumerated()), id: \.element.id) { index, activity in
                FerneCard(padding: FerneSpacing.sm) {
                    ActivityRow(
                        activity: activity.toSnapshot(),
                        isInProgress: activity.status == .enCurso
                    ) {
                        confirm(activity)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared || reduceMotion ? 0 : 12)
                .animation(FerneMotion.entrance(index: index, reduceMotion: reduceMotion), value: appeared)
                // Deslizar para confirmar; el menú da el resto de acciones.
                .contextMenu { actions(for: activity) }
                .accessibilityActions { actions(for: activity) }
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

    /// Tocar el check nunca completa a ciegas: pregunta por el resultado.
    private func confirm(_ activity: ActivityRecord) {
        guard activity.status.isOpen else {
            ActivityRepository(context: context).reopen(activity)
            return
        }
        Haptics.shared.tap(.soft)
        pendingConfirmation = activity
    }

    private func apply(_ status: ActivityStatus, to activity: ActivityRecord) {
        let repository = ActivityRepository(context: context)
        withAnimation(reduceMotion ? .easeOut(duration: FerneMotion.quick) : FerneMotion.card) {
            switch status {
            case .completada:
                repository.complete(activity)
                Haptics.shared.success()
            case .parcial:
                repository.markPartial(activity)
                Haptics.shared.tap(.light)
            case .omitida:
                repository.markSkipped(activity)
                Haptics.shared.tap(.soft)
            default:
                break
            }
        }
        pendingConfirmation = nil
    }

    private func reschedule(_ activity: ActivityRecord) {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: activity.startDate) else { return }
        withAnimation(reduceMotion ? .easeOut(duration: FerneMotion.quick) : FerneMotion.card) {
            ActivityRepository(context: context).reschedule(activity, to: tomorrow)
        }
        Haptics.shared.tap(.light)
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
}
