import SwiftData
import SwiftUI

/// Pantalla 28 — Perfil y ajustes. Todo lo respondido en el onboarding es editable
/// aquí, más las acciones destructivas, que piden confirmación explícita (§13).
struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(ThemeController.self) private var themeController
    @Environment(UserPreferences.self) private var preferences

    @Query private var allActivities: [ActivityRecord]

    @State private var name: String = ""
    @State private var isConfirmingReset = false
    @State private var isConfirmingDelete = false
    @State private var isConfirmingDeleteFinal = false

    var body: some View {
        FerneScreen(sceneIntensity: 0.55) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    Text("Perfil")
                        .font(FerneFont.greeting)
                        .foregroundStyle(FerneColor.brandMagenta)
                        .padding(.top, 150)

                    nameCard
                    greetingPreviewCard
                    scheduleCard
                    categoriesCard
                    toneCard
                    soundCard
                    accessibilityCard
                    dangerCard
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("screen.profile")
        .onAppear { name = preferences.preferredName }
    }

    // MARK: - Nombre y saludo

    private var nameCard: some View {
        SettingsCard(title: "CÓMO TE LLAMO") {
            TextField("Fer", text: $name)
                .font(FerneFont.sectionTitle)
                .foregroundStyle(FerneColor.textPrimary)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .frame(minHeight: FerneSize.minimumTapTarget)
                .onSubmit { preferences.preferredName = name }
                .accessibilityLabel("Tu nombre")
            Button("Guardar nombre") {
                preferences.preferredName = name
                Haptics.shared.tap(.light)
            }
            .buttonStyle(.ferneSecondary)
        }
    }

    private var greetingPreviewCard: some View {
        SettingsCard(title: "TU SALUDO") {
            ForEach(DayPhase.allCases, id: \.self) { phase in
                HStack {
                    Image(systemName: phase.celestialBody == .moon ? "moon.stars.fill" : "sun.max.fill")
                        .foregroundStyle(FerneColor.sunGold)
                    Text(phase.greeting(name: name.isEmpty ? preferences.preferredName : name))
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textPrimary)
                }
                .frame(minHeight: FerneSize.minimumTapTarget, alignment: .leading)
            }
        }
    }

    // MARK: - Horarios y categorías

    private var scheduleCard: some View {
        SettingsCard(title: "TUS HORARIOS") {
            ScheduleRow(label: "Despertar", time: preferences.wakeTime)
            ScheduleRow(label: "Desayuno", time: preferences.breakfastTime)
            ScheduleRow(label: "Almuerzo", time: preferences.lunchTime)
            ScheduleRow(label: "Cena", time: preferences.dinnerTime)
            ScheduleRow(label: "Dormir", time: preferences.sleepTime)
            Text("Para cambiarlos, vuelve a hacer el onboarding desde el final de esta pantalla.")
                .font(FerneFont.meta)
                .foregroundStyle(FerneColor.textTertiary)
        }
    }

    private var categoriesCard: some View {
        SettingsCard(title: "LO QUE ORGANIZAS") {
            let selected = preferences.selectedCategories.sorted { $0.displayName < $1.displayName }
            if selected.isEmpty {
                Text("Todavía no elegiste categorías.")
                    .font(FerneFont.secondary)
                    .foregroundStyle(FerneColor.textSecondary)
            } else {
                ForEach(selected, id: \.self) { category in
                    HStack {
                        Image(systemName: category.symbolName)
                            .foregroundStyle(FerneColor.categoryTint(category))
                            .frame(width: 26)
                        Text(category.displayName)
                            .font(FerneFont.body)
                            .foregroundStyle(FerneColor.textPrimary)
                        Spacer()
                    }
                    .frame(minHeight: FerneSize.minimumTapTarget)
                }
            }
        }
    }

    // MARK: - Preferencias

    private var toneCard: some View {
        SettingsCard(title: "CÓMO TE ACOMPAÑO") {
            Toggle("Mensajes motivacionales", isOn: Binding(
                get: { preferences.wantsDailyMessage },
                set: { preferences.wantsDailyMessage = $0 }
            ))
            .tint(FerneColor.accentPrimary)

            Toggle("Recordatorios amables", isOn: Binding(
                get: { preferences.wantsGentleReminders },
                set: { preferences.wantsGentleReminders = $0 }
            ))
            .tint(FerneColor.accentPrimary)

            Toggle("Vibración", isOn: Binding(
                get: { preferences.hapticsEnabled },
                set: { preferences.hapticsEnabled = $0 }
            ))
            .tint(FerneColor.accentPrimary)
        }
    }

    private var soundCard: some View {
        SettingsCard(title: "SONIDO") {
            SoundPicker(selection: Binding(
                get: { preferences.preferredSoundID },
                set: { preferences.preferredSoundID = $0 }
            ))
            Text("Los archivos de sonido aún no están incluidos. Mientras tanto se usa el sonido del sistema.")
                .font(FerneFont.meta)
                .foregroundStyle(FerneColor.textTertiary)
        }
    }

    private var accessibilityCard: some View {
        SettingsCard(title: "ACCESIBILIDAD") {
            // FERNÉ no ofrece su propio interruptor de Reduce Motion: respeta el de
            // iOS. Duplicarlo confundiría sobre cuál manda.
            Label(
                "FERNÉ respeta Reducir movimiento y Reducir transparencia de iOS",
                systemImage: "figure.walk.motion"
            )
            .font(FerneFont.secondary)
            .foregroundStyle(FerneColor.textSecondary)
            Label("El texto sigue el tamaño que elijas en Ajustes", systemImage: "textformat.size")
                .font(FerneFont.secondary)
                .foregroundStyle(FerneColor.textSecondary)
        }
    }

    // MARK: - Acciones destructivas

    private var dangerCard: some View {
        SettingsCard(title: "DATOS") {
            Text("Tienes \(allActivities.count) actividad(es) guardadas en este iPhone.")
                .font(FerneFont.secondary)
                .foregroundStyle(FerneColor.textSecondary)

            Button("Repetir la bienvenida") { isConfirmingReset = true }
                .buttonStyle(.ferneSecondary)

            Button {
                isConfirmingDelete = true
            } label: {
                Text("Borrar todos mis datos")
                    .font(FerneFont.button)
                    .foregroundStyle(FerneColor.criticalRed)
                    .frame(maxWidth: .infinity, minHeight: FerneSize.minimumTapTarget)
            }
            .buttonStyle(.plain)
        }
        .confirmationDialog(
            "¿Repetir la bienvenida?",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("Repetir") { preferences.resetOnboarding() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Volverás a responder las preguntas iniciales. Tus actividades no se tocan.")
        }
        .confirmationDialog(
            "¿Borrar todos tus datos?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Continuar", role: .destructive) { isConfirmingDeleteFinal = true }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text(
                "Se eliminarán tus \(allActivities.count) actividad(es), tu nombre, tus horarios y tus preferencias. No se puede deshacer."
            )
        }
        .confirmationDialog(
            "Esto no se puede deshacer",
            isPresented: $isConfirmingDeleteFinal,
            titleVisibility: .visible
        ) {
            Button("Sí, borrar todo", role: .destructive) { deleteEverything() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Última confirmación.")
        }
    }

    private func deleteEverything() {
        ActivityRepository(context: context).deleteAll()
        preferences.resetEverything()
        name = preferences.preferredName
        Haptics.shared.warning()
    }
}

// MARK: - Piezas

private struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        FerneCard {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text(title)
                    .font(FerneFont.labelCaps)
                    .kerning(1.2)
                    .foregroundStyle(FerneColor.textTertiary)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ScheduleRow: View {
    let label: String
    let time: Date?

    var body: some View {
        HStack {
            Text(label)
                .font(FerneFont.body)
                .foregroundStyle(FerneColor.textPrimary)
            Spacer()
            Text(time.map { HomeView.time($0) } ?? "Sin definir")
                .font(FerneFont.cardTitle)
                .foregroundStyle(time == nil ? FerneColor.textTertiary : FerneColor.brandMagenta)
        }
        .frame(minHeight: FerneSize.minimumTapTarget)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Perfil") {
    NavigationStack { ProfileView() }
        .environment(ThemeController.preview(.noche))
        .environment(UserPreferences())
        .modelContainer(for: ActivityRecord.self, inMemory: true)
}
