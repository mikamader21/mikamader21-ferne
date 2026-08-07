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

    /// `true` bajo cualquier modo de prueba.
    public static var isActive: Bool {
        arguments.contains("-FERNEUITest") || environment["FERNE_UITEST"] == "1" || isRuntimeSmoke
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

    /// Fuerza que el onboarding se dé por hecho.
    ///
    /// Un simulador limpio no tiene preferencias guardadas: sin esto, cualquier
    /// prueba que quiera empezar en Inicio se toparía con el onboarding y fallaría
    /// por un motivo que no estaba probando.
    public static var skipsOnboarding: Bool {
        value(for: "-FERNESkipOnboarding") == "1"
    }

    // MARK: - Modo smoke de ejecución

    /// Modo de las pruebas de humo en tiempo de ejecución.
    ///
    /// Distinto del modo de capturas: aquí **no se siembra nada**. El almacén es
    /// real, en disco y aislado, para que la persistencia entre lanzamientos pueda
    /// probarse de verdad. Con datos de preview no se probaría nada.
    public static var isRuntimeSmoke: Bool {
        arguments.contains("-FERNERuntimeSmoke") || environment["FERNE_RUNTIME_SMOKE"] == "1"
    }

    /// Borra el almacén aislado antes de arrancar. Solo el primer lanzamiento de
    /// cada escenario lo usa; el relanzamiento de persistencia reutiliza el mismo.
    public static var resetsStore: Bool {
        arguments.contains("-FERNEResetStore") || environment["FERNE_RESET_STORE"] == "1"
    }

    /// Suite de `UserDefaults` aislada para el modo smoke, para que los ajustes
    /// tampoco contaminen ni se contaminen entre escenarios.
    public static let runtimeSmokeSuiteName = "com.ferne.app.runtimesmoke"

    /// Carpeta del almacén aislado.
    public static var runtimeSmokeStoreURL: URL? {
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        ) else { return nil }
        return support.appendingPathComponent("FERNE-RuntimeSmoke.store")
    }

    /// Fuerza que el onboarding se dé por hecho.
    ///
    /// Necesario porque un simulador limpio no tiene preferencias guardadas: sin
    /// esto, cualquier prueba que quiera empezar en Inicio se toparía con el
    /// onboarding y fallaría por un motivo que no estaba probando.
    public static var skipsOnboarding: Bool {
        value(for: "-FERNESkipOnboarding") == "1"
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
