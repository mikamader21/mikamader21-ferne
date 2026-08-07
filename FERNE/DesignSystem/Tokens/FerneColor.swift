import SwiftUI

/// Paleta de FERNÉ.
///
/// **Única fuente de color de la app.** Ninguna vista debe declarar un hex propio;
/// SwiftLint bloquea `Color(hex: "#…")` fuera de este archivo.
///
/// La paleta tiene **dos grupos con reglas distintas** (decisión D-022):
///
/// - **Funcionales** (§4.2 de la especificación): rosas, coral, dorado, ciruela, blanco
///   cálido, verde de completado y ámbar de atención. Son los colores de la interfaz:
///   botones, texto, tarjetas, estados y navegación.
/// - **Atmosféricos** (derivados de `01-splash-approved.png`): cian cielo, lavanda, índigo
///   suave, rosa de amanecer, melocotón y ciruela nocturno. Solo pueden aparecer en cielos,
///   transiciones, reflejos, halos y partículas. **Nunca** en botones, formularios ni
///   navegación.
///
/// Cuando la referencia visual y la lista inicial de §4.2 difieren de forma demostrable,
/// **manda la referencia**.
public enum FerneColor {
    // MARK: - Funcionales · paleta base

    /// `#FFF8F7` — Fondo base.
    public static let ivoryRose = Color(hex: 0xFFF8F7)
    /// `#FFFCFB` — Tarjetas.
    public static let warmWhite = Color(hex: 0xFFFCFB)
    /// `#FADCE6` — Superficies suaves.
    public static let cloudPink = Color(hex: 0xFADCE6)
    /// `#F7A3BE` — Acentos secundarios.
    public static let softPink = Color(hex: 0xF7A3BE)
    /// `#F45F92` — Acción principal.
    public static let fernePink = Color(hex: 0xF45F92)
    /// `#F7A39A` — Amanecer y gradientes.
    public static let peachCoral = Color(hex: 0xF7A39A)
    /// `#F6C978` — Sol y destacados.
    public static let sunGold = Color(hex: 0xF6C978)
    /// `#3C102F` — Títulos.
    public static let deepPlum = Color(hex: 0x3C102F)
    /// `#672846` — Texto e iconos.
    public static let secondaryPlum = Color(hex: 0x672846)
    /// `#876D79` — Texto secundario.
    public static let roseGray = Color(hex: 0x876D79)
    /// `#9FD4B4` — Completado / pagado.
    public static let successSoft = Color(hex: 0x9FD4B4)
    /// `#F4B86A` — Atención no crítica.
    public static let attentionAmber = Color(hex: 0xF4B86A)

    // MARK: - Atmosféricos

    //
    // Muestreados de `docs/design-references/01-splash-approved.png`.
    // Uso EXCLUSIVO en escenas: cielo, transiciones, reflejos, halos y partículas.
    // Prohibidos en botones, formularios, navegación, texto y estados.

    /// `#69E6FC` — Cian cielo. Presente en la esquina superior derecha del Splash.
    public static let skyCyan = Color(hex: 0x69E6FC)
    /// `#B0A6EA` — Índigo suave. Esquina inferior derecha del Splash.
    public static let softIndigo = Color(hex: 0xB0A6EA)
    /// `#C6AFD3` — Lavanda. Zona media derecha del Splash y transición nocturna.
    public static let lavender = Color(hex: 0xC6AFD3)
    /// `#FF88A8` — Rosa de amanecer. Esquina superior izquierda del Splash.
    public static let dawnPink = Color(hex: 0xFF88A8)
    /// `#FFB68C` — Melocotón de amanecer. Esquina inferior izquierda del Splash.
    public static let dawnPeach = Color(hex: 0xFFB68C)
    /// `#8A5E86` — Ciruela nocturno. Transición entre `deepPlum` y la lavanda.
    public static let nightPlum = Color(hex: 0x8A5E86)
    /// Los seis colores atmosféricos, para auditoría y pruebas.
    public static let atmospheric: [Color] = [
        skyCyan, softIndigo, lavender, dawnPink, dawnPeach, nightPlum
    ]

    // MARK: - Rojo reservado

    /// `#FDF3F6` — Blanco luminoso nacarado. Núcleo de la luna, destellos, halos
    /// y realce de texto sobre la escena. Es **funcional**, no atmosférico: puede
    /// aparecer en cualquier capa.
    public static let luminousWhite = Color(hex: 0xFDF3F6)

    /// **Uso restringido.** Solo errores técnicos y pagos vencidos (§4.2).
    /// Nunca para juzgar hábitos, score ni actividades sin completar.
    public static let criticalRed = Color(hex: 0xD64545)

    // MARK: - Roles semánticos

    public static let background = ivoryRose
    public static let surface = warmWhite
    public static let surfaceSoft = cloudPink
    public static let accentPrimary = fernePink
    public static let accentSecondary = softPink
    public static let textPrimary = deepPlum
    public static let textSecondary = secondaryPlum
    public static let textTertiary = roseGray
    public static let positive = successSoft
    public static let attention = attentionAmber

    /// Borde sutil de tarjeta (§4.4).
    public static let cardBorder = softPink.opacity(0.22)
    /// Sombra rosada ligera (§4.4).
    public static let cardShadow = fernePink.opacity(0.14)

    // MARK: - Degradados

    /// Botón principal: degradado **oro → magenta**.
    ///
    /// La referencia manda: en `03-progress-approved.png` el botón "Organizar mañana" va de
    /// dorado a magenta, de izquierda a derecha. `DESIGN-TOKENS.md` lo confirma
    /// ("Morning Gold to Coral Pink"). Sustituye al rosa→coral de la Fase 0.
    public static let primaryButtonGradient = LinearGradient(
        colors: [sunGold, fernePink],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Magenta profundo de marca, para titulares editoriales y trazos de progreso.
    /// Es el `primary` de `DESIGN-TOKENS.md`, distinto de `fernePink` (que es el relleno
    /// de acción). En las tres referencias, "Buenos días, Fer", "82" y "FERNÉ" usan este.
    public static let brandMagenta = Color(hex: 0xAE275D)

    /// Color de una categoría. Los mismos valores de siempre, agrupados por el
    /// momento del día al que pertenece cada categoría.
    public static func categoryTint(_ category: ActivityCategory) -> Color {
        rhythmTint(category) ?? activityTint(category) ?? personalTint(category)
    }

    /// Categorías que marcan el ritmo del día: despertar, comer, dormir.
    private static func rhythmTint(_ category: ActivityCategory) -> Color? {
        switch category {
        case .despertar: sunGold
        case .comida: peachCoral
        case .dormir: deepPlum
        default: nil
        }
    }

    /// Categorías de actividad programada.
    private static func activityTint(_ category: ActivityCategory) -> Color? {
        switch category {
        case .gym: fernePink
        case .trabajo: secondaryPlum
        case .live: softPink
        case .lectura: cloudPink
        case .pago: attentionAmber
        default: nil
        }
    }

    /// Rutinas, eventos, notas y espacio personal.
    private static func personalTint(_ category: ActivityCategory) -> Color {
        switch category {
        case .rutina: softPink
        case .nota: roseGray
        default: fernePink
        }
    }

    public static func statusTint(_ status: ActivityStatus) -> Color {
        switch status {
        case .completada: successSoft
        case .pendiente: attentionAmber
        case .reprogramada: softPink
        case .programada: secondaryPlum
        case .omitida: roseGray
        case .cancelada: roseGray
        }
    }
}

public extension Color {
    /// Inicializador interno del design system. No usar fuera de `FerneColor`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
