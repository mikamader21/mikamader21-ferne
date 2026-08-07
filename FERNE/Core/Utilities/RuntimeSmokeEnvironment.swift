import Foundation

/// Entorno aislado de las pruebas de humo en tiempo de ejecución.
///
/// Cada escenario recibe su propio identificador (`FERNE_RUNTIME_TEST_ID`), y con él
/// un almacén de SwiftData y una suite de `UserDefaults` exclusivos. Sin esto, A
/// contaminaba a B, B a C, y una ejecución anterior de CI a la siguiente.
///
/// **Orden de inicialización.** La limpieza no puede vivir en `FerneApp.init()`:
/// los inicializadores de propiedad de la estructura —incluido
/// `@State var preferences = UserPreferences()`— se evalúan **antes** del cuerpo del
/// init. Por eso `resetIfNeeded()` se invoca desde `UserPreferences.init` y desde
/// `ModelContainerFactory.make()`, y se apoya en un `static let` para ejecutarse
/// exactamente una vez, sea cual sea el que llegue primero.
public enum RuntimeSmokeEnvironment {
    private static let arguments = ProcessInfo.processInfo.arguments
    private static let environment = ProcessInfo.processInfo.environment

    /// Identificador del escenario en curso. `nil` fuera del modo smoke.
    public static var testID: String? {
        guard UITestConfiguration.isRuntimeSmoke else { return nil }
        if let index = arguments.firstIndex(of: "-FERNERuntimeTestID"), index + 1 < arguments.count {
            return arguments[index + 1]
        }
        return environment["FERNE_RUNTIME_TEST_ID"]
    }

    /// Sufijo estable para separar los almacenes. Sin identificador, todos los
    /// escenarios compartirían uno solo.
    private static var slug: String {
        let raw = testID ?? "default"
        return raw.filter { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
    }

    /// Suite de `UserDefaults` exclusiva del escenario.
    public static var defaultsSuiteName: String {
        "com.ferne.app.runtimesmoke.\(slug)"
    }

    /// Almacén de SwiftData exclusivo del escenario.
    public static var storeURL: URL? {
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        ) else { return nil }
        return support.appendingPathComponent("FERNE-RuntimeSmoke-\(slug).store")
    }

    /// Ejecuta la limpieza **una sola vez** por proceso.
    ///
    /// `static let` es perezoso y seguro frente a concurrencia, y al ser inmutable
    /// no introduce estado global mutable. Es la forma de garantizar el orden sin
    /// una bandera que Swift 6 rechazaría.
    private static let cleanupPerformed: Bool = {
        performCleanup()
        return true
    }()

    public static func resetIfNeeded() {
        _ = cleanupPerformed
    }

    private static func performCleanup() {
        guard UITestConfiguration.isRuntimeSmoke, UITestConfiguration.resetsStore else { return }

        let manager = FileManager.default
        if let url = storeURL {
            // SQLite deja tres archivos: el principal más -shm y -wal. Borrar solo
            // el primero deja el almacén en un estado inconsistente.
            for suffix in ["", "-shm", "-wal"] {
                try? manager.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }
        UserDefaults.standard.removePersistentDomain(forName: defaultsSuiteName)
        UserDefaults(suiteName: defaultsSuiteName)?.removePersistentDomain(forName: defaultsSuiteName)
    }
}
