import SwiftUI

/// Pantalla 06 — Menú Agregar. Hoja con las diez categorías de creación.
struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss

    /// Categoría elegida. El editor se presenta desde aquí.
    @State private var chosen: ActivityCategory?

    /// Las diez entradas del menú, en el orden del encargo.
    private static let options: [(category: ActivityCategory, label: String)] = [
        (.despertar, "Despertar"),
        (.comida, "Comida"),
        (.gym, "Gym"),
        (.trabajo, "Trabajo"),
        (.live, "TikTok Live"),
        (.lectura, "Lectura"),
        (.pago, "Pago o recibo"),
        (.dormir, "Dormir"),
        (.personal, "Tiempo personal"),
        (.evento, "Recordatorio libre")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SkyScene(intensity: 0.45)
                grid
            }
            .navigationTitle("¿Qué quieres agregar?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .navigationDestination(item: $chosen) { category in
                ActivityEditorView(category: category) { dismiss() }
            }
        }
        // `.contain` publica el contenedor como nodo consultable sin ocultar
        // sus hijos. Sin esto el identificador existe pero no hay elemento
        // que lo lleve, y la automatización no puede encontrarlo.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("screen.addMenu")
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: FerneSpacing.sm)],
                spacing: FerneSpacing.sm
            ) {
                ForEach(Self.options, id: \.label) { option in
                    Button {
                        Haptics.shared.tap(.soft)
                        chosen = option.category
                    } label: {
                        AddOptionTile(category: option.category, label: option.label)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("addMenu.\(option.category.rawValue)")
                }
            }
            .padding(FerneSpacing.screenHorizontal)
        }
        .scrollContentBackground(.hidden)
    }
}

private struct AddOptionTile: View {
    let category: ActivityCategory
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
            Image(systemName: category.symbolName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(FerneColor.categoryTint(category))
                .frame(width: FerneSize.categoryIcon, height: FerneSize.categoryIcon)
                .background { Circle().fill(FerneColor.surfaceSoft) }
            Text(label)
                .font(FerneFont.cardTitle)
                .foregroundStyle(FerneColor.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(FerneSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                .fill(FerneColor.surface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: FerneRadius.card, style: .continuous)
                .strokeBorder(FerneColor.cardBorder, lineWidth: 1)
        }
        .shadow(color: FerneColor.cardShadow, radius: 10, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}

/// Necesario para `navigationDestination(item:)`.
extension ActivityCategory: Identifiable {
    public var id: String {
        rawValue
    }
}

#Preview("Menú agregar") { AddActivitySheet() }
