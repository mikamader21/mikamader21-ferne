import SwiftData
import SwiftUI

/// Formulario de creación de una actividad. Guarda en SwiftData: al confirmar,
/// aparece de inmediato en Inicio y sobrevive al cierre de la app.
struct ActivityEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let category: ActivityCategory
    let onSaved: () -> Void

    @State private var title: String = ""
    @State private var startDate: Date = .init()
    @State private var hasDuration: Bool = false
    @State private var durationMinutes: Int = 60
    @State private var repeats: Bool = false
    @State private var frequency: RecurrenceRule.Frequency = .diaria
    @State private var weekdays: Set<Int> = []
    @State private var wantsNotification: Bool = true
    @State private var leadMinutes: Int = 10
    @State private var soundID: String = SoundLibrary.systemSoundID
    @State private var priority: Priority = .normal
    @State private var notes: String = ""

    private static let leadOptions = [0, 5, 10, 15, 30, 60]
    private static let durationOptions = [15, 30, 45, 60, 90, 120]

    /// Las opciones estándar más la sugerida de la categoría, si no estuviera.
    private var durationChoices: [Int] {
        Set(Self.durationOptions + [category.suggestedDurationMinutes]).sorted()
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Ni siquiera un formulario lleva fondo plano: la escena queda debajo,
            // atenuada para que los controles se lean bien (§14.3).
            SkyScene(intensity: 0.4)
            form
        }
        .navigationTitle("Nueva actividad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") { save() }
                    .disabled(!canSave)
                    .accessibilityIdentifier("editor.save")
            }
        }
        .onAppear(perform: applyDefaults)
        .accessibilityIdentifier("screen.activityEditor")
    }

    private var form: some View {
        Form {
            Section("Actividad") {
                TextField("Título", text: $title)
                    .font(FerneFont.body)
                    .accessibilityLabel("Título de la actividad")
                LabeledContent("Categoría") {
                    Label(category.displayName, systemImage: category.symbolName)
                        .foregroundStyle(FerneColor.categoryTint(category))
                }
            }

            Section("Cuándo") {
                DatePicker("Fecha y hora", selection: $startDate)
                Toggle("Duración", isOn: $hasDuration)
                    .tint(FerneColor.accentPrimary)
                if hasDuration {
                    Picker("Duración", selection: $durationMinutes) {
                        ForEach(durationChoices, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                }
            }

            Section("Repetición") {
                Toggle("Se repite", isOn: $repeats)
                    .tint(FerneColor.accentPrimary)
                if repeats {
                    Picker("Cada", selection: $frequency) {
                        ForEach(RecurrenceRule.Frequency.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    if frequency == .personalizada {
                        WeekdaySelector(selection: $weekdays)
                    }
                }
            }

            Section("Aviso") {
                Toggle("Avisarme", isOn: $wantsNotification)
                    .tint(FerneColor.accentPrimary)
                if wantsNotification {
                    Picker("Anticipación", selection: $leadMinutes) {
                        ForEach(Self.leadOptions, id: \.self) { minutes in
                            Text(minutes == 0 ? "A la hora" : "\(minutes) min antes").tag(minutes)
                        }
                    }
                    NavigationLink("Sonido") {
                        List { SoundPicker(selection: $soundID) }
                            .navigationTitle("Sonido")
                    }
                    // La programación real de la alerta llega en la Fase 4. Aquí se
                    // guarda la preferencia; no se promete una entrega que todavía
                    // no existe (§8.1).
                    Text("Los avisos se programarán cuando se active el sistema de notificaciones.")
                        .font(FerneFont.meta)
                        .foregroundStyle(FerneColor.textTertiary)
                }
            }

            Section("Detalles") {
                Picker("Prioridad", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                TextField("Notas", text: $notes, axis: .vertical)
                    .lineLimit(2 ... 5)
            }
        }
        .scrollContentBackground(.hidden)
    }

    /// Valores iniciales sensatos según la categoría, para que Fer escriba lo menos posible.
    private func applyDefaults() {
        guard title.isEmpty else { return }
        title = category.displayName
        priority = category.isKeySchedule ? .esencial : .normal
        // Toda actividad necesita una ventana para poder preguntar por su resultado.
        // Se propone la de su categoría y Fer la puede cambiar.
        durationMinutes = category.suggestedDurationMinutes
        hasDuration = true
    }

    private func save() {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }

        let rule: RecurrenceRule? = repeats
            ? RecurrenceRule(frequency: frequency, interval: 1, weekdays: weekdays)
            : nil
        let end: Date? = hasDuration
            ? Calendar.ferneDefault.date(byAdding: .minute, value: durationMinutes, to: startDate)
            : nil
        let offsets: [TimeInterval] = wantsNotification ? [TimeInterval(leadMinutes * 60)] : []

        let record = ActivityRecord(
            title: clean,
            notes: notes.isEmpty ? nil : notes,
            category: category,
            startDate: startDate,
            endDate: end,
            recurrence: rule,
            reminderOffsets: offsets,
            soundID: wantsNotification ? soundID : nil,
            priority: priority,
            requiresConfirmation: category.isKeySchedule
        )

        // `create` programa las alertas; si el permiso está denegado no programa
        // nada y lo deja escrito en el log, sin prometer entrega.
        ActivityRepository(context: context).create(record)
        Haptics.shared.success()
        onSaved()
    }
}

/// Selector de días de la semana, en formato `Calendar` (1 = domingo … 7 = sábado).
private struct WeekdaySelector: View {
    @Binding var selection: Set<Int>

    private let labels = [(2, "L"), (3, "M"), (4, "X"), (5, "J"), (6, "V"), (7, "S"), (1, "D")]

    var body: some View {
        HStack(spacing: FerneSpacing.xxs) {
            ForEach(labels, id: \.0) { value, label in
                let isOn = selection.contains(value)
                Button {
                    if isOn {
                        selection.remove(value)
                    } else {
                        selection.insert(value)
                    }
                } label: {
                    Text(label)
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(isOn ? .white : FerneColor.textSecondary)
                        .frame(width: FerneSize.minimumTapTarget, height: FerneSize.minimumTapTarget)
                        .background {
                            Circle().fill(isOn ? FerneColor.accentPrimary : FerneColor.surfaceSoft)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(label)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
    }
}
