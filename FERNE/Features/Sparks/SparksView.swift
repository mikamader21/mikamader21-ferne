import SwiftData
import SwiftUI

/// Pestaña Destellos (MASTER_SPEC §5): mensaje del día y espacio personal.
///
/// Nada inventado: sin actividades no hay recomendaciones, porque una recomendación
/// necesita una observación verificable detrás (§9.3).
struct SparksView: View {
    @Environment(ThemeController.self) private var themeController
    @Environment(UserPreferences.self) private var preferences

    @Query private var allActivities: [ActivityRecord]

    /// Magenta sobre cielo claro, blanco luminoso sobre cielo nocturno.
    private var titleColor: Color {
        themeController.theme.hasDarkAtmosphere ? FerneColor.luminousWhite : FerneColor.brandMagenta
    }

    var body: some View {
        FerneScreen(sceneIntensity: 0.7) {
            ScrollView {
                VStack(alignment: .leading, spacing: FerneSpacing.md) {
                    AtmosphericText {
                        Text("Destellos")
                            .font(FerneFont.greeting)
                            .foregroundStyle(titleColor)
                    }
                    .padding(.top, 150)

                    FerneCard {
                        VStack(alignment: .leading, spacing: FerneSpacing.xs) {
                            Text("MENSAJE DE HOY")
                                .font(FerneFont.labelCaps)
                                .kerning(1.2)
                                .foregroundStyle(FerneColor.textTertiary)
                            Text(message)
                                .font(FerneFont.body)
                                .foregroundStyle(FerneColor.textPrimary)
                        }
                    }

                    if allActivities.isEmpty {
                        FerneCard(padding: FerneSpacing.lg) {
                            VStack(spacing: FerneSpacing.xs) {
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 34, weight: .light))
                                    .foregroundStyle(FerneColor.accentSecondary)
                                Text("Las recomendaciones llegarán solas")
                                    .font(FerneFont.sectionTitle)
                                    .foregroundStyle(FerneColor.textPrimary)
                                Text("Cuando lleves unos días organizando, aquí verás qué te funciona mejor.")
                                    .font(FerneFont.secondary)
                                    .foregroundStyle(FerneColor.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, FerneSpacing.screenHorizontal)
                .padding(.bottom, FerneSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
        }
        // `.contain` publica el contenedor como nodo consultable sin ocultar
        // sus hijos. Sin esto el identificador existe pero no hay elemento
        // que lo lleve, y la automatización no puede encontrarlo.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("screen.sparks")
    }

    private var message: String {
        guard preferences.wantsDailyMessage else {
            return "Tienes los mensajes desactivados. Puedes volver a activarlos en Perfil."
        }
        // `return` explícito en cada caso: el getter tiene un `guard` antes, así que
        // no es de una sola expresión y el retorno implícito no aplica.
        switch themeController.phase {
        case .manana: return "Hoy no tienes que hacerlo todo. Solo lo que importa, a tu ritmo."
        case .tarde: return "Si algo se movió de sitio, no pasa nada. Sigues avanzando."
        case .noche: return "Cerrar el día también cuenta. Descansa bien, \(preferences.preferredName)."
        }
    }
}

#Preview("Destellos") {
    NavigationStack { SparksView() }
        .environment(ThemeController.preview(.manana))
        .environment(UserPreferences())
        .modelContainer(for: ActivityRecord.self, inMemory: true)
}
