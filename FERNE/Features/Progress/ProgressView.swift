import SwiftUI

/// Pantalla 36 — Mi progreso (MASTER_SPEC §6.36).
/// Fase 0: esqueleto con score real calculado sobre `PreviewData`. Gráficas en Fase 5.
struct ProgressView: View {
    @Environment(ThemeController.self) private var theme

    private var weekly: WeeklyScore {
        ScoreEngine().weeklyScore(weekContaining: Date(), activities: PreviewData.week)
    }

    var body: some View {
        FerneScreen(sceneIntensity: 0.55) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    Text("Mi progreso")
                        .font(FerneFont.greeting)
                        .foregroundStyle(theme.theme.titleColor)
                        .padding(.top, FerneSpacing.xl)

                    FerneCard {
                        VStack(alignment: .leading, spacing: FerneSpacing.sm) {
                            HStack(spacing: FerneSpacing.md) {
                                FerneProgressRing(
                                    value: weekly.rawScore / 100,
                                    label: "Semana",
                                    diameter: 104
                                )
                                Text(weekly.state.message)
                                    .font(FerneFont.cardTitle)
                                    .foregroundStyle(FerneColor.textPrimary)
                                Spacer(minLength: 0)
                            }

                            Divider().overlay(FerneColor.cardBorder)

                            ForEach(weekly.breakdown, id: \.label) { item in
                                VStack(alignment: .leading, spacing: FerneSpacing.xxs) {
                                    HStack {
                                        Text(item.label)
                                            .font(FerneFont.secondary)
                                            .foregroundStyle(FerneColor.textSecondary)
                                        Spacer()
                                        Text("\(Int(item.value.rounded()))% · peso \(Int(item.weight * 100))%")
                                            .font(FerneFont.meta)
                                            .foregroundStyle(FerneColor.textTertiary)
                                    }
                                    FerneProgressBar(value: item.value / 100, accessibilityLabel: item.label)
                                }
                            }
                        }
                    }

                    FerneCard {
                        Text(WeeklyScore.disclaimer)
                            .font(FerneFont.secondary)
                            .foregroundStyle(FerneColor.textSecondary)
                    }
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("screen.progress")
    }
}

#Preview("Progreso") {
    NavigationStack { ProgressView() }.environment(ThemeController.preview(.tarde))
}
