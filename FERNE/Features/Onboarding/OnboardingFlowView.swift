import SwiftUI
import UserNotifications

/// Onboarding paginado. Solo aparece en el primer ingreso: al terminar se guarda
/// `hasCompletedOnboarding` y no vuelve a mostrarse. Todo es editable desde Perfil.
///
/// El permiso de notificaciones se pide **únicamente** cuando Fer pulsa "Activar
/// recordatorios" (MASTER_SPEC §6.03: cada permiso en contexto, nunca de golpe).
struct OnboardingFlowView: View {
    @Environment(\.ferneTheme) private var theme
    @Environment(ThemeController.self) private var themeController

    let preferences: UserPreferences
    let onFinish: () -> Void

    @State private var page = 0
    @State private var draft = OnboardingDraft()
    @State private var notificationOutcome: NotificationOutcome = .notAsked

    private let lastPage = 6

    enum NotificationOutcome: Equatable {
        case notAsked
        case granted
        case denied
    }

    var body: some View {
        ZStack {
            SkyScene(intensity: 0.85)

            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, FerneSpacing.screenHorizontal)
                    .padding(.top, FerneSpacing.md)

                TabView(selection: $page) {
                    namePage.tag(0)
                    categoriesPage.tag(1)
                    wakePage.tag(2)
                    schedulePage.tag(3)
                    tonePage.tag(4)
                    notificationsPage.tag(5)
                    finalPage.tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                controls
                    .padding(.horizontal, FerneSpacing.screenHorizontal)
                    .padding(.bottom, FerneSpacing.lg)
            }
        }
        .accessibilityIdentifier("screen.onboarding")
    }

    // MARK: - Cabecera

    private var progressBar: some View {
        HStack(spacing: FerneSpacing.xxs) {
            ForEach(0 ... lastPage, id: \.self) { index in
                Capsule()
                    .fill(index <= page ? FerneColor.brandMagenta : FerneColor.cloudPink)
                    .frame(height: 4)
            }
        }
        .animation(FerneMotion.ease, value: page)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Paso \(page + 1) de \(lastPage + 1)")
    }

    // MARK: - Páginas

    private var namePage: some View {
        OnboardingPage(title: "Hola ✨", subtitle: "¿Cómo quieres que te llame?") {
            FerneCard {
                TextField("Fer", text: $draft.name)
                    .font(FerneFont.greeting)
                    .foregroundStyle(FerneColor.brandMagenta)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .frame(minHeight: FerneSize.minimumTapTarget)
                    .accessibilityLabel("Tu nombre")
            }
            Text("Puedes cambiarlo cuando quieras desde tu perfil.")
                .font(FerneFont.secondary)
                .foregroundStyle(theme.secondaryOnAtmosphere)
        }
    }

    private var categoriesPage: some View {
        OnboardingPage(title: "¿Qué quieres organizar conmigo?", subtitle: "Elige lo que te acompañe. Puedes cambiarlo después.") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: FerneSpacing.sm)], spacing: FerneSpacing.sm) {
                ForEach(OnboardingDraft.offeredCategories, id: \.self) { category in
                    CategoryChoiceCard(
                        category: category,
                        isSelected: draft.categories.contains(category)
                    ) {
                        toggle(category)
                    }
                }
            }
        }
    }

    private var wakePage: some View {
        OnboardingPage(title: "¿Cómo suele comenzar tu día?", subtitle: "Sin prisa. Solo para acompañarte mejor.") {
            FerneCard {
                VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                    DatePicker("Hora de despertar", selection: $draft.wakeTime, displayedComponents: .hourAndMinute)
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textPrimary)
                    Divider().overlay(FerneColor.cardBorder)
                    Toggle("Quiero un recordatorio para despertar", isOn: $draft.wantsWakeReminder)
                        .font(FerneFont.secondary)
                        .foregroundStyle(FerneColor.textSecondary)
                        .tint(FerneColor.accentPrimary)
                }
            }
        }
    }

    private var schedulePage: some View {
        OnboardingPage(title: "Cuidemos tus horarios", subtitle: "Todos son opcionales. Activa solo los que uses.") {
            FerneCard {
                VStack(spacing: FerneSpacing.sm) {
                    OptionalTimeRow(label: "Desayuno", isOn: $draft.wantsBreakfast, time: $draft.breakfastTime)
                    Divider().overlay(FerneColor.cardBorder)
                    OptionalTimeRow(label: "Almuerzo", isOn: $draft.wantsLunch, time: $draft.lunchTime)
                    Divider().overlay(FerneColor.cardBorder)
                    OptionalTimeRow(label: "Cena", isOn: $draft.wantsDinner, time: $draft.dinnerTime)
                    Divider().overlay(FerneColor.cardBorder)
                    OptionalTimeRow(label: "Hora de dormir", isOn: $draft.wantsSleep, time: $draft.sleepTime)
                }
            }
        }
    }

    private var tonePage: some View {
        OnboardingPage(title: "¿Cómo quieres que te acompañe?", subtitle: "Puedes ajustarlo en cualquier momento.") {
            FerneCard {
                VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                    Toggle("Mensajes motivacionales", isOn: $draft.wantsDailyMessage)
                        .tint(FerneColor.accentPrimary)
                    Divider().overlay(FerneColor.cardBorder)
                    Toggle("Recordatorios amables", isOn: $draft.wantsGentleReminders)
                        .tint(FerneColor.accentPrimary)
                    Divider().overlay(FerneColor.cardBorder)
                    Toggle("Vibración", isOn: $draft.hapticsEnabled)
                        .tint(FerneColor.accentPrimary)
                }
                .font(FerneFont.body)
                .foregroundStyle(FerneColor.textPrimary)
            }

            FerneCard {
                VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                    Text("SONIDO PREFERIDO")
                        .font(FerneFont.labelCaps)
                        .kerning(1.2)
                        .foregroundStyle(FerneColor.textTertiary)
                    SoundPicker(selection: $draft.soundID)
                }
            }
        }
    }

    private var notificationsPage: some View {
        OnboardingPage(title: "Recordatorios", subtitle: "Para avisarte a tiempo, sin agobiarte.") {
            FerneCard {
                VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                    Label("Te aviso de comidas, gym, lives y pagos", systemImage: "bell.badge")
                    Label("Solo lo que tú programes. Nada más", systemImage: "hand.raised")
                    Label("Puedes desactivarlo cuando quieras", systemImage: "slider.horizontal.3")
                }
                .font(FerneFont.secondary)
                .foregroundStyle(FerneColor.textSecondary)
            }

            switch notificationOutcome {
            case .notAsked:
                Button("Activar recordatorios") {
                    Task { await requestNotifications() }
                }
                .buttonStyle(.fernePrimary)
            case .granted:
                Label("Recordatorios activados", systemImage: "checkmark.circle.fill")
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(FerneColor.positive)
                    .frame(minHeight: FerneSize.minimumTapTarget)
            case .denied:
                // Honestidad: si iOS lo bloqueó, no se promete entrega (§8.1).
                VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                    Label("Los avisos están desactivados en iOS", systemImage: "bell.slash")
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(FerneColor.attention)
                    Text("Puedes activarlos en Ajustes cuando quieras. FERNÉ funciona igual, pero no podrá avisarte.")
                        .font(FerneFont.secondary)
                        .foregroundStyle(FerneColor.textSecondary)
                }
            }
        }
    }

    private var finalPage: some View {
        OnboardingPage(
            title: "Todo listo, \(draft.resolvedName) ✨",
            subtitle: "Vamos a construir un día bonito."
        ) {
            Image(systemName: theme.celestialBody == .moon ? "moon.stars.fill" : "sun.horizon.fill")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(FerneColor.sunGold)
                .padding(.vertical, FerneSpacing.md)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Controles

    private var controls: some View {
        VStack(spacing: FerneSpacing.xs) {
            Button(page == lastPage ? "Comenzar" : "Continuar") {
                advance()
            }
            .buttonStyle(.fernePrimary)
            .disabled(page == 0 && draft.resolvedName.isEmpty)

            if page > 0, page < lastPage {
                Button("Atrás") {
                    withAnimation(FerneMotion.ease) { page -= 1 }
                }
                .buttonStyle(.ferneSecondary)
            }
        }
    }

    // MARK: - Acciones

    private func toggle(_ category: ActivityCategory) {
        Haptics.shared.tap(.soft)
        withAnimation(FerneMotion.enter) {
            if draft.categories.contains(category) {
                draft.categories.remove(category)
            } else {
                draft.categories.insert(category)
            }
        }
    }

    private func advance() {
        Haptics.shared.tap(.light)
        guard page < lastPage else {
            finish()
            return
        }
        withAnimation(FerneMotion.ease) { page += 1 }
    }

    private func finish() {
        draft.apply(to: preferences)
        preferences.hasCompletedOnboarding = true
        themeController.refresh()
        Haptics.shared.success()
        onFinish()
    }

    private func requestNotifications() async {
        preferences.notificationsRequested = true
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            notificationOutcome = granted ? .granted : .denied
        } catch {
            FerneLog.notifications.error("Fallo al pedir permiso de notificaciones")
            notificationOutcome = .denied
        }
    }
}

// MARK: - Piezas reutilizables del onboarding

/// Estructura común de todas las páginas: título editorial, subtítulo y contenido.
private struct OnboardingPage<Content: View>: View {
    @Environment(\.ferneTheme) private var theme
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FerneSpacing.md) {
                VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
                    Text(title)
                        .font(FerneFont.greeting)
                        .foregroundStyle(theme.textOnAtmosphere)
                    Text(subtitle)
                        .font(FerneFont.secondary)
                        .foregroundStyle(theme.secondaryOnAtmosphere)
                }
                .padding(.top, FerneSpacing.xl)

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FerneSpacing.screenHorizontal)
            .padding(.bottom, FerneSpacing.xl)
        }
        .scrollContentBackground(.hidden)
    }
}

/// Tarjeta de categoría seleccionable, con animación al elegir.
private struct CategoryChoiceCard: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.ferneReduceMotionOverride) private var reduceMotionOverride

    let category: ActivityCategory
    let isSelected: Bool
    let action: () -> Void

    private var reduceMotion: Bool {
        reduceMotionOverride ?? systemReduceMotion
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : FerneColor.categoryTint(category))
                    .frame(width: FerneSize.categoryIcon, height: FerneSize.categoryIcon)
                    .background {
                        Circle().fill(isSelected ? FerneColor.categoryTint(category) : FerneColor.surfaceSoft)
                    }
                Text(category.displayName)
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(FerneColor.textPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding(FerneSpacing.sm)
            .background {
                RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                    .strokeBorder(
                        isSelected ? FerneColor.brandMagenta : FerneColor.cardBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(color: FerneColor.cardShadow, radius: isSelected ? 16 : 8, y: 6)
            .scaleEffect(isSelected && !reduceMotion ? 1.03 : 1)
            .animation(reduceMotion ? nil : FerneMotion.elasticCheck, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.displayName)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// Fila de horario opcional: interruptor + selector de hora.
private struct OptionalTimeRow: View {
    let label: String
    @Binding var isOn: Bool
    @Binding var time: Date

    var body: some View {
        VStack(spacing: FerneSpacing.xxs) {
            Toggle(label, isOn: $isOn)
                .font(FerneFont.body)
                .foregroundStyle(FerneColor.textPrimary)
                .tint(FerneColor.accentPrimary)
            if isOn {
                DatePicker(label, selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityLabel("Hora de \(label)")
            }
        }
        .frame(minHeight: FerneSize.minimumTapTarget)
    }
}

/// Selector de sonido. Muestra el estado real: si el archivo no está en el bundle,
/// se dice, en lugar de prometer un sonido que no puede sonar.
struct SoundPicker: View {
    @Binding var selection: String

    var body: some View {
        VStack(spacing: 0) {
            ForEach(SoundLibrary.all) { sound in
                Button {
                    selection = sound.id
                    Haptics.shared.tap(.soft)
                } label: {
                    HStack {
                        Image(systemName: selection == sound.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(FerneColor.accentPrimary)
                        Text(sound.displayName)
                            .font(FerneFont.body)
                            .foregroundStyle(FerneColor.textPrimary)
                        Spacer()
                        Text(sound.isAvailable ? "Listo" : "Pendiente")
                            .font(FerneFont.meta)
                            .foregroundStyle(sound.isAvailable ? FerneColor.positive : FerneColor.textTertiary)
                    }
                    .frame(minHeight: FerneSize.minimumTapTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(sound.displayName), \(sound.isAvailable ? "disponible" : "pendiente")")
                .accessibilityAddTraits(selection == sound.id ? [.isSelected] : [])
            }

            Button {
                selection = SoundLibrary.systemSoundID
                Haptics.shared.tap(.soft)
            } label: {
                HStack {
                    Image(systemName: selection == SoundLibrary.systemSoundID ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(FerneColor.accentPrimary)
                    Text("Sonido del sistema")
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textPrimary)
                    Spacer()
                }
                .frame(minHeight: FerneSize.minimumTapTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
