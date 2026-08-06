import SwiftUI

/// Pantalla 28 — Perfil y ajustes (MASTER_SPEC §6.28).
/// Fase 0: esqueleto de navegación y vista previa del saludo por franja.
/// Ajustes reales (notificaciones, sonidos, privacidad, Face ID, iCloud) en Fases 4 y 6.
struct ProfileView: View {
    @Environment(ThemeController.self) private var theme
    @AppStorage("ferne.user.preferredName") private var preferredName = "Fer"

    var body: some View {
        FerneScreen(sceneIntensity: 0.5) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    Text("Perfil")
                        .font(FerneFont.greeting)
                        .foregroundStyle(theme.theme.titleColor)
                        .padding(.top, FerneSpacing.xl)

                    // Pantalla 29 — Personalizar saludo: vista previa mañana/tarde/noche.
                    FerneCard {
                        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                            Text("Tu saludo")
                                .font(FerneFont.meta)
                                .foregroundStyle(FerneColor.textTertiary)
                            ForEach(DayPhase.allCases, id: \.self) { phase in
                                Text(phase.greeting(name: preferredName))
                                    .font(FerneFont.body)
                                    .foregroundStyle(FerneColor.textPrimary)
                            }
                        }
                    }

                    FerneCard {
                        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                            Text("Sonidos")
                                .font(FerneFont.cardTitle)
                                .foregroundStyle(FerneColor.textPrimary)
                            ForEach(SoundLibrary.all) { sound in
                                HStack {
                                    Text(sound.displayName)
                                        .font(FerneFont.body)
                                        .foregroundStyle(FerneColor.textSecondary)
                                    Spacer()
                                    // Honestidad: si el archivo no está en el bundle, se dice.
                                    Text(sound.isAvailable ? "Listo" : "Pendiente")
                                        .font(FerneFont.meta)
                                        .foregroundStyle(
                                            sound.isAvailable ? FerneColor.positive : FerneColor.textTertiary
                                        )
                                }
                                .frame(minHeight: FerneSize.minimumTapTarget)
                            }
                        }
                    }
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        .accessibilityIdentifier("screen.profile")
    }
}

#Preview("Perfil") {
    NavigationStack { ProfileView() }.environment(ThemeController.preview(.noche))
}
