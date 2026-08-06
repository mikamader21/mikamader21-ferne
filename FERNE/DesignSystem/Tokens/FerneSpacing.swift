import SwiftUI

/// Escala de espaciado, radios y tamaños táctiles.
public enum FerneSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48

    /// Margen horizontal estándar de pantalla.
    public static let screenHorizontal: CGFloat = 20
}

public enum FerneRadius {
    /// Radio de tarjeta: 20–24 pt (§4.4).
    public static let card: CGFloat = 22
    public static let cardLarge: CGFloat = 24
    public static let control: CGFloat = 16
    public static let pill: CGFloat = 999
}

public enum FerneSize {
    /// Área táctil mínima obligatoria (§13).
    public static let minimumTapTarget: CGFloat = 44
    public static let fab: CGFloat = 60
    public static let categoryIcon: CGFloat = 40
}

public enum FerneShadow {
    /// Sombra rosada ligera de tarjeta (§4.4).
    public static let cardRadius: CGFloat = 18
    public static let cardY: CGFloat = 8
}
