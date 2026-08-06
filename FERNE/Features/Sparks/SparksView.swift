import SwiftUI

/// Pestaña Destellos (MASTER_SPEC §5): mensaje del día, recomendaciones y espacio personal.
/// Fase 0: esqueleto con el formato obligatorio de recomendación (§9.3). Contenido real en Fases 5–6.
struct SparksView: View {
    @Environment(ThemeController.self) private var theme

    var body: some View {
        FerneScreen(sceneIntensity: 0.6) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    Text("Destellos")
                        .font(FerneFont.greeting)
                        .foregroundStyle(theme.theme.titleColor)
                        .padding(.top, FerneSpacing.xl)

                    FerneCard {
                        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                            Text("Mensaje de hoy")
                                .font(FerneFont.meta)
                                .foregroundStyle(FerneColor.textTertiary)
                            Text(PreviewData.dailyMessage)
                                .font(FerneFont.body)
                                .foregroundStyle(FerneColor.textPrimary)
                        }
                    }

                    RecommendationCard(recommendation: .example)
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("screen.sparks")
    }
}

/// Pantalla 39 — Recomendaciones FERNÉ. Siempre explica **por qué** y **qué cambiará**.
struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        FerneCard {
            VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                Text(recommendation.observation)
                    .font(FerneFont.cardTitle)
                    .foregroundStyle(FerneColor.textPrimary)
                Text(recommendation.explanation)
                    .font(FerneFont.secondary)
                    .foregroundStyle(FerneColor.textSecondary)
                Text(recommendation.suggestedChange)
                    .font(FerneFont.secondary)
                    .foregroundStyle(FerneColor.textTertiary)
                if let actionLabel = recommendation.actionLabel {
                    Button(actionLabel) {}
                        .buttonStyle(.ferneSecondary)
                        .padding(.top, FerneSpacing.xxs)
                }
            }
        }
    }
}

#Preview("Destellos") {
    NavigationStack { SparksView() }.environment(ThemeController.preview(.manana))
}
