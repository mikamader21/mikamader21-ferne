import SwiftUI

/// Pantalla 04 — Inicio / Hoy (MASTER_SPEC §6.04).
///
/// **Fase 0: esqueleto verificable.** Muestra saludo dinámico, escena día/noche,
/// anillo "Mi día" y "Lo que sigue" con datos de preview. La lógica real
/// (SwiftData, cuenta regresiva, acciones por actividad) llega en Fases 1–2.
struct HomeView: View {
    @Environment(ThemeController.self) private var theme
    @State private var isShowingAddMenu = false

    private let preferredName = "Fer"

    var body: some View {
        FerneScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    header
                    dayCard
                    nextUpCard
                    agendaSection
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)

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
        .navigationTitle("")
        .accessibilityIdentifier("screen.home")
        .sheet(isPresented: $isShowingAddMenu) {
            // Pantalla 06 — Menú Agregar. Se implementa en la Fase 2.
            FerneEmptyState(
                symbol: "plus.circle",
                title: "Menú Agregar",
                message: "Disponible en la Fase 2."
            )
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
            Text(theme.greeting(for: preferredName))
                .font(FerneFont.greeting)
                .foregroundStyle(theme.theme.titleColor)
            Text(PreviewData.todayLongDate)
                .font(FerneFont.meta)
                .foregroundStyle(theme.theme.bodyColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, FerneSpacing.xl)
        .accessibilityElement(children: .combine)
    }

    private var dayCard: some View {
        FerneCard {
            HStack(spacing: FerneSpacing.md) {
                FerneProgressRing(value: PreviewData.dayProgress, label: "Mi día", diameter: 96)
                VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
                    Text("\(PreviewData.completedCount) de \(PreviewData.evaluableCount) completadas")
                        .font(FerneFont.cardTitle)
                        .foregroundStyle(FerneColor.textPrimary)
                    Text("Vas a tu ritmo.")
                        .font(FerneFont.secondary)
                        .foregroundStyle(FerneColor.textTertiary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var nextUpCard: some View {
        FerneCard {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text("Lo que sigue")
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textTertiary)
                if let next = PreviewData.nextActivity {
                    ActivityRow(activity: next)
                } else {
                    Text("Nada pendiente ahora mismo ✨")
                        .font(FerneFont.body)
                        .foregroundStyle(FerneColor.textSecondary)
                }
            }
        }
    }

    private var agendaSection: some View {
        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
            Text("Agenda del día")
                .font(FerneFont.sectionTitle)
                .foregroundStyle(theme.theme.titleColor)
                .padding(.top, FerneSpacing.xs)

            ForEach(PreviewData.today) { activity in
                FerneCard(padding: FerneSpacing.sm) {
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

/// Fila de actividad reutilizable. Nunca depende solo del color para comunicar estado (§13).
struct ActivityRow: View {
    let activity: ActivitySnapshot

    var body: some View {
        HStack(spacing: FerneSpacing.sm) {
            Image(systemName: activity.category.symbolName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FerneColor.categoryTint(activity.category))
                .frame(width: FerneSize.categoryIcon, height: FerneSize.categoryIcon)
                .background(Circle().fill(FerneColor.surfaceSoft))

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(FerneColor.textPrimary)
                Text("\(PreviewData.time(activity.startDate)) · \(activity.category.displayName)")
                    .font(FerneFont.meta)
                    .foregroundStyle(FerneColor.textTertiary)
            }

            Spacer(minLength: 0)

            FerneCheckmark(isChecked: activity.isCompleted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(activity.title), \(activity.category.displayName), \(PreviewData.time(activity.startDate))")
        .accessibilityValue(activity.status.displayName)
        .accessibilityHint("Toca dos veces para abrir el detalle")
    }
}

#Preview("Inicio · mañana") {
    NavigationStack { HomeView() }.environment(ThemeController.preview(.manana))
}

#Preview("Inicio · noche") {
    NavigationStack { HomeView() }.environment(ThemeController.preview(.noche))
}
