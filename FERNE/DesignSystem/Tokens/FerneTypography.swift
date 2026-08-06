import SwiftUI

/// Tipografía de FERNÉ.
///
/// Decisión **D-023** (sustituye a D-003): se adoptan dos fuentes con licencia
/// **SIL Open Font License 1.1**, especificadas en `docs/design-references/DESIGN-TOKENS.md`:
///
/// | Familia | Uso |
/// |---|---|
/// | **Libre Caslon Text** | Logotipo, saludos y titulares editoriales |
/// | **Hanken Grotesk** | Textos de marca, subtítulos y contenido general |
/// | **SF Pro / sistema** | Controles nativos pequeños y casos de accesibilidad |
///
/// **Todo escala con Dynamic Type.** Las fuentes personalizadas no escalan solas: cada
/// declaración usa `relativeTo:` para anclarla a un estilo del sistema. Quitarlo rompería
/// la accesibilidad de forma silenciosa.
///
/// **Fallback automático:** si un archivo `.ttf` no está registrado en el bundle,
/// `FerneFont` devuelve la fuente del sistema con el mismo diseño (serif o sans). La app
/// nunca se rompe por una fuente ausente; solo cambia su carácter.
public enum FerneFont {
    // MARK: - Familias

    enum Family {
        static let serif = "LibreCaslonText-Regular"
        static let serifBold = "LibreCaslonText-Bold"
        static let sans = "HankenGrotesk-Regular"
        static let sansMedium = "HankenGrotesk-Medium"
        static let sansSemibold = "HankenGrotesk-SemiBold"
        static let sansBold = "HankenGrotesk-Bold"

        /// Todas las fuentes que la app espera encontrar en el bundle.
        static let all = [serif, serifBold, sans, sansMedium, sansSemibold, sansBold]
    }

    /// `true` si la fuente está realmente registrada en el sistema.
    ///
    /// No se cachea a propósito: `UIFont(name:)` es barato y así una fuente añadida en
    /// caliente durante el desarrollo se detecta sin reiniciar.
    static func isRegistered(_ name: String) -> Bool {
        #if canImport(UIKit)
            return UIFont(name: name, size: 12) != nil
        #else
            return false
        #endif
    }

    /// Fuente personalizada con caída a la del sistema.
    ///
    /// - Parameters:
    ///   - name: nombre PostScript de la fuente.
    ///   - style: estilo de texto al que se ancla para Dynamic Type.
    ///   - size: tamaño base en puntos.
    ///   - fallbackDesign: diseño del sistema que se usa si la fuente no está.
    ///   - fallbackWeight: peso del sistema para el fallback.
    private static func custom(
        _ name: String,
        relativeTo style: Font.TextStyle,
        size: CGFloat,
        fallbackDesign: Font.Design,
        fallbackWeight: Font.Weight = .regular
    ) -> Font {
        guard isRegistered(name) else {
            return .system(style, design: fallbackDesign).weight(fallbackWeight)
        }
        return .custom(name, size: size, relativeTo: style)
    }

    // MARK: - Editorial · Libre Caslon Text

    /// Logotipo y títulos de escena (Splash, Día completado, Celebración).
    public static var display: Font {
        custom(
            Family.serifBold,
            relativeTo: .largeTitle,
            size: 40,
            fallbackDesign: .serif,
            fallbackWeight: .bold
        )
    }

    /// Saludo de Inicio: "Buenos días, Fer ✨".
    public static var greeting: Font {
        custom(
            Family.serifBold,
            relativeTo: .title,
            size: 30,
            fallbackDesign: .serif,
            fallbackWeight: .semibold
        )
    }

    /// Encabezado de sección: "Agenda de hoy", "Así va tu semana".
    public static var sectionTitle: Font {
        custom(
            Family.serif,
            relativeTo: .title3,
            size: 22,
            fallbackDesign: .serif,
            fallbackWeight: .semibold
        )
    }

    // MARK: - Funcional · Hanken Grotesk

    /// Título de tarjeta.
    public static var cardTitle: Font {
        custom(
            Family.sansSemibold,
            relativeTo: .headline,
            size: 17,
            fallbackDesign: .default,
            fallbackWeight: .semibold
        )
    }

    /// Cuerpo.
    public static var body: Font {
        custom(Family.sans, relativeTo: .body, size: 17, fallbackDesign: .default)
    }

    /// Texto secundario.
    public static var secondary: Font {
        custom(Family.sans, relativeTo: .subheadline, size: 15, fallbackDesign: .default)
    }

    /// Metadatos: hora, categoría. Solo texto NO esencial.
    public static var meta: Font {
        custom(
            Family.sansMedium,
            relativeTo: .footnote,
            size: 13,
            fallbackDesign: .default,
            fallbackWeight: .medium
        )
    }

    /// Etiqueta en versales, con espaciado ampliado. Aplicar `.kerning(1.2)` en la vista.
    /// En las referencias: "MI DÍA", "LO QUE SIGUE", "COMPLETADAS".
    public static var labelCaps: Font {
        custom(
            Family.sansBold,
            relativeTo: .caption,
            size: 12,
            fallbackDesign: .default,
            fallbackWeight: .bold
        )
    }

    /// Cifra grande del score: "82", "78%".
    public static var scoreNumber: Font {
        custom(
            Family.serifBold,
            relativeTo: .largeTitle,
            size: 44,
            fallbackDesign: .serif,
            fallbackWeight: .bold
        )
    }

    /// Etiqueta de botón.
    public static var button: Font {
        custom(
            Family.sansSemibold,
            relativeTo: .headline,
            size: 17,
            fallbackDesign: .default,
            fallbackWeight: .semibold
        )
    }

    // MARK: - Reglas

    /// Tamaño mínimo permitido para texto esencial (§4.3).
    public static let minimumEssentialPointSize: CGFloat = 14

    /// Diagnóstico: qué fuentes faltan realmente en el bundle.
    /// Lo usa `Scripts/verify-fonts.sh` y la pantalla de Perfil en desarrollo.
    public static var missingFonts: [String] {
        Family.all.filter { !isRegistered($0) }
    }
}
