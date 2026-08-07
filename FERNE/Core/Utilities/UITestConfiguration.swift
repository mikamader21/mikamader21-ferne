import Foundation

/// Configuración inyectada por los UI tests mediante argumentos de lanzamiento.
///
/// Existe porque desde Windows la única forma de ver FERNÉ es a través de las
/// capturas que genera el runner macOS. Para que esas capturas sirvan como QA
/// visual, el test debe poder fijar la franja horaria, el conjunto de datos y
/// el estado de accesibilidad **sin depender de la hora del simulador**.
///
/// Solo se activa cuando el proceso recibe `-FERNEUITest 1`. En un build normal
/// todas las propiedades devuelven `nil` y la app se comporta como siempre.
public enum UITestConfiguration {
    private static let arguments = ProcessInfo.processInfo.arguments
    private static let environment = ProcessInfo.processInfo.environment

    /// `true` solo bajo UI tests.
    public static var isActive: Bool {
        arguments.contains("-FERNEUITest") || environment["FERNE_UITEST"] == "1"
    }

    private static func value(for key: String) -> String? {
        guard isActive else { return nil }
        if let index = arguments.firstIndex(of: key), index + 1 < arguments.count {
            return arguments[index + 1]
        }
        return environment[key.replacingOccurrences(of: "-", with: "")]
    }

    /// Franja horaria forzada. Permite capturar mañana, tarde y noche en la misma ejecución.
    public static var forcedPhase: DayPhase? {
        value(for: "-FERNEPhase").flatMap(DayPhase.init(rawValue:))
    }

    /// Conjunto de datos de la captura.
    public enum Fixture: String {
        /// Día típico: algunas completadas, algunas pendientes.
        case mixto
        /// Todo completado.
        case completo
        /// Sin actividades: estado vacío.
        case vacio
    }

    public static var fixture: Fixture {
        value(for: "-FERNEFixture").flatMap(Fixture.init(rawValue:)) ?? .mixto
    }

    /// Salta la escena del splash para que la captura no dependa del temporizador.
    public static var skipsSplash: Bool {
        value(for: "-FERNESkipSplash") == "1"
    }

    /// Fuerza que el onboarding vuelva a aparecer, para poder capturarlo.
    /// Solo tiene efecto bajo UI tests.
    public static var resetsOnboarding: Bool {
        value(for: "-FERNEResetOnboarding") == "1"
    }

    /// Fuerza el comportamiento de Reduce Motion **a nivel de app**.
    ///
    /// **Limitación honesta:** esto NO activa el ajuste real de iOS. Sirve para
    /// capturar cómo se ve la app cuando decide reducir movimiento, pero la
    /// conformidad real con `accessibilityReduceMotion` debe verificarse
    /// activando el ajuste del sistema en un dispositivo o simulador.
    public static var forcesReduceMotion: Bool {
        value(for: "-FERNEReduceMotion") == "1"
    }
}
