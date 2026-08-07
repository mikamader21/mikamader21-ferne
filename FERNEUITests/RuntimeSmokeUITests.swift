import XCTest

/// Pruebas de humo en tiempo de ejecucion.
///
/// Los textos van sin acentos ni caracteres de dibujo a proposito: el log de
/// GitHub Actions los rompia y el diagnostico quedaba ilegible justo cuando mas
/// falta hacia.
///
/// Dos correcciones de diseno respecto a la version anterior, que fallo cuatro de
/// cuatro sin llegar a tocar la interfaz:
///
/// 1. **Selectores agnosticos de tipo.** Los identificadores de pantalla se buscan
///    con `descendants(matching: .any)`. SwiftUI no garantiza que un contenedor se
///    publique como `.other`, y buscar solo ahi hacia que ninguna pantalla
///    apareciera aunque estuviera en pantalla.
/// 2. **El splash no es requisito.** Dura unos 2 s y la sesion de automatizacion
///    tardo 76 s en establecerse: exigir verlo era pedir lo imposible. Se registra
///    si aparece, nunca se exige.
///
/// Cada escenario usa su propio almacen (`FERNE_RUNTIME_TEST_ID`). A, B y C
/// arrancan limpios; D comparte almacen entre sus dos lanzamientos.
final class RuntimeSmokeUITests: XCTestCase {
    private var trail = Trail()
    private var currentTestID = ""
    private var currentReset = true

    /// Un solo timeout por transicion. La version anterior encadenaba esperas de
    /// 25 s + 30 s y consumia minutos buscando la primera pantalla.
    private enum Timeout {
        /// Primera pantalla tras `launch()`: incluye arranque en frio.
        static let firstScreen: TimeInterval = 30
        /// Transicion entre pantallas con la app ya viva.
        static let transition: TimeInterval = 15
        /// Elemento dentro de una pantalla ya presente.
        static let element: TimeInterval = 10
        /// Dialogo del sistema, que puede no llegar a aparecer.
        static let systemDialog: TimeInterval = 8
    }

    override func setUp() {
        continueAfterFailure = false
        trail = Trail()
    }

    // MARK: - A · Onboarding omitiendo notificaciones

    @MainActor
    func testA_OnboardingWithoutNotificationsReachesHome() {
        let app = launch(testID: "A", resetStore: true)
        noteSplashIfVisible(app)

        completeOnboarding(app, notifications: .skip)
        assertHomeIsUsable(app, scenario: "A · sin notificaciones")
    }

    // MARK: - B · Onboarding activando notificaciones

    @MainActor
    func testB_OnboardingWithNotificationsReachesHome() {
        let app = launch(testID: "B", resetStore: true)
        noteSplashIfVisible(app)

        completeOnboarding(app, notifications: .enable)
        assertHomeIsUsable(app, scenario: "B · con notificaciones")
    }

    // MARK: - C · Crear Gym y verlo en Progreso

    @MainActor
    func testC_CreateGymAndSeeItInProgress() {
        let app = launch(testID: "C", resetStore: true)
        completeOnboarding(app, notifications: .skip)
        assertHomeIsUsable(app, scenario: "C · llegada a Inicio")

        createGym(in: app)

        trail.step("comprobando la tarjeta en Inicio", page: "home")
        let cardShown = screen(app, "activity.row.gym").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(cardShown, diagnosis(app, "La actividad creada no aparecio en Inicio."))

        trail.step("abriendo Progreso", page: "progress")
        let progressTab = app.tabBars.buttons["Progreso"]
        let tabShown = progressTab.waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(tabShown, diagnosis(app, "Falta la pestana Progreso."))
        progressTab.tap()

        let progressShown = screen(app, "screen.progress").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(progressShown, diagnosis(app, "Progreso no se abrio."))
        assertAlive(app, "C: la app se cerro al abrir Progreso.")
    }

    // MARK: - D · Persistencia entre lanzamientos

    @MainActor
    func testD_DataSurvivesRelaunch() {
        // Primer lanzamiento: almacen limpio.
        let first = launch(testID: "D", resetStore: true)
        completeOnboarding(first, notifications: .skip)
        assertHomeIsUsable(first, scenario: "D · primer lanzamiento")

        createGym(in: first)
        let created = screen(first, "activity.row.gym").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(created, diagnosis(first, "La actividad no se creo en el primer lanzamiento."))
        first.terminate()

        // Segundo lanzamiento: MISMO identificador, sin borrar. Es lo unico que
        // demuestra que los datos sobreviven.
        trail.step("relanzando con el mismo almacen", page: "relaunch")
        let second = launch(testID: "D", resetStore: false)

        trail.step("esperando Inicio directamente", page: "home")
        let homeShown = screen(second, "screen.home").waitForExistence(timeout: Timeout.firstScreen)
        XCTAssertTrue(homeShown, diagnosis(second, "Tras relanzar no se llego a Inicio."))

        let onboardingBack = screen(second, "screen.onboarding").exists
        XCTAssertFalse(onboardingBack, diagnosis(second, "El onboarding reaparecio: no se guardo que ya se completo."))

        let survived = screen(second, "activity.row.gym").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(survived, diagnosis(second, "La actividad no sobrevivio al relanzamiento."))
        assertAlive(second, "D: la app se cerro tras relanzar.")
    }

    // MARK: - Selectores

    /// Busca un identificador **sin suponer su tipo**.
    ///
    /// Es la correccion central: SwiftUI publica un contenedor como `.other`,
    /// `.group`, `.scrollView` u otro segun el caso, y buscar solo en
    /// `otherElements` hacia que la pantalla nunca apareciera.
    @MainActor
    private func screen(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    /// El splash es opcional: si esta, se anota; si no, no pasa nada.
    @MainActor
    private func noteSplashIfVisible(_ app: XCUIApplication) {
        if screen(app, "screen.splash").exists {
            trail.step("splash visible (opcional)", page: "splash")
        } else {
            trail.step("splash no visible; se continua", page: "splash")
        }
    }

    // MARK: - Onboarding

    private enum NotificationChoice { case enable, skip }

    @MainActor
    private func completeOnboarding(_ app: XCUIApplication, notifications: NotificationChoice) {
        trail.step("esperando el onboarding", page: "onboarding")
        let shown = screen(app, "screen.onboarding").waitForExistence(timeout: Timeout.firstScreen)
        XCTAssertTrue(shown, diagnosis(app, "El onboarding no aparecio en una instalacion limpia."))

        for page in 0 ... 6 {
            trail.step("pagina \(page)", page: "onboarding.\(page)")
            assertAlive(app, "La app se cerro en la pagina \(page) del onboarding.")

            if page == 5 {
                resolveNotifications(app, choice: notifications)
            }

            let identifier = page == 6 ? "onboarding.finish" : "onboarding.advance"
            let button = app.buttons[identifier]
            let ready = button.waitForExistence(timeout: Timeout.element)
            guard ready else {
                XCTFail(diagnosis(app, "No aparecio '\(identifier)' en la pagina \(page)."))
                return
            }
            trail.step("pulsando '\(identifier)'", page: "onboarding.\(page)", element: identifier)
            button.tap()
            assertAlive(app, "La app se cerro al pulsar '\(identifier)' en la pagina \(page).")
        }
    }

    @MainActor
    private func resolveNotifications(_ app: XCUIApplication, choice: NotificationChoice) {
        let identifier = choice == .skip ? "onboarding.skipNotifications" : "onboarding.enableNotifications"
        let button = app.buttons[identifier]
        let ready = button.waitForExistence(timeout: Timeout.element)
        guard ready else {
            trail.step("no aparecio '\(identifier)'; se continua", page: "onboarding.5")
            return
        }
        trail.step("pulsando '\(identifier)'", page: "onboarding.5", element: identifier)
        button.tap()

        if choice == .enable {
            resolveSystemPermissionDialog(app)
        }
        assertAlive(app, "La app se cerro al resolver los recordatorios.")
    }

    /// Acepta o rechaza el dialogo de iOS. Ambos caminos deben dejar la app en pie:
    /// si el permiso se deniega, FERNE tiene que seguir funcionando.
    @MainActor
    private func resolveSystemPermissionDialog(_ app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let labels = ["Permitir", "Allow", "No permitir", "Don't Allow", "Don\u{2019}t Allow"]

        let deadline = Date().addingTimeInterval(Timeout.systemDialog)
        while Date() < deadline {
            for label in labels {
                let button = springboard.buttons[label]
                if button.exists, button.isHittable {
                    trail.step("dialogo del sistema: '\(label)'", page: "onboarding.5", element: label)
                    button.tap()
                    _ = app.wait(for: .runningForeground, timeout: Timeout.element)
                    return
                }
            }
            _ = springboard.buttons.firstMatch.waitForExistence(timeout: 1)
        }
        trail.step("el dialogo del sistema no aparecio", page: "onboarding.5")
    }

    @MainActor
    private func createGym(in app: XCUIApplication) {
        trail.step("pulsando el boton +", page: "home")
        let fab = app.buttons["home.fab"]
        let fabReady = fab.waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(fabReady, diagnosis(app, "No se encontro el boton +."))
        fab.tap()

        trail.step("esperando el menu de creacion", page: "addMenu")
        let menuShown = screen(app, "screen.addMenu").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(menuShown, diagnosis(app, "El menu de creacion no se abrio."))

        trail.step("eligiendo Gym", page: "addMenu")
        let gym = app.buttons["addMenu.gym"]
        let gymReady = gym.waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(gymReady, diagnosis(app, "No se encontro la categoria Gym."))
        gym.tap()

        trail.step("esperando el editor", page: "editor")
        let editorShown = screen(app, "screen.activityEditor").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(editorShown, diagnosis(app, "El editor de actividad no se abrio."))

        trail.step("guardando", page: "editor")
        let save = app.buttons["editor.save"]
        let saveReady = save.waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(saveReady, diagnosis(app, "No se encontro el boton Guardar."))
        save.tap()
    }

    // MARK: - Comprobaciones

    /// Llegar a Inicio **y que Inicio sea usable**. Estar en primer plano no basta:
    /// una pantalla en blanco tambien lo estaria.
    @MainActor
    private func assertHomeIsUsable(_ app: XCUIApplication, scenario: String) {
        trail.step("esperando Inicio", page: "home")
        let homeShown = screen(app, "screen.home").waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(homeShown, diagnosis(app, "\(scenario): no se llego a Inicio."))

        let tabBarShown = app.tabBars.firstMatch.waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(tabBarShown, diagnosis(app, "\(scenario): Inicio sin barra de pestanas."))

        let fabShown = app.buttons["home.fab"].waitForExistence(timeout: Timeout.element)
        XCTAssertTrue(fabShown, diagnosis(app, "\(scenario): Inicio sin boton + utilizable."))

        assertAlive(app, "\(scenario): la app no estaba en primer plano.")
    }

    @MainActor
    private func launch(testID: String, resetStore: Bool) -> XCUIApplication {
        currentTestID = testID
        currentReset = resetStore

        let app = XCUIApplication()
        app.launchArguments += [
            "-FERNERuntimeSmoke",
            "-FERNERuntimeTestID", testID,
            "-FERNESkipSplash", "1",
            "-FERNESkipOnboarding", "0"
        ]
        if resetStore {
            app.launchArguments.append("-FERNEResetStore")
        }
        app.launchEnvironment["FERNE_RUNTIME_SMOKE"] = "1"
        app.launchEnvironment["FERNE_RUNTIME_TEST_ID"] = testID
        trail.step("lanzando (id \(testID), reset \(resetStore))", page: "launch")
        app.launch()
        return app
    }

    // MARK: - Diagnostico

    @MainActor
    private func assertAlive(_ app: XCUIApplication, _ message: String) {
        guard app.state != .runningForeground else { return }
        XCTFail(diagnosis(app, message))
    }

    /// Informe completo del punto de fallo, en ASCII para que el log de Actions no
    /// lo rompa. Se adjunta al `.xcresult`.
    @MainActor
    private func diagnosis(_ app: XCUIApplication, _ message: String) -> String {
        let visible = visibleScreenIdentifiers(app)
        let report = """
        ----------------------------------------
        \(message)
        ----------------------------------------
        FERNE_RUNTIME_TEST_ID   : \(currentTestID)
        Almacen                 : \(currentReset ? "reset (limpio)" : "reutilizado (sin borrar)")
        Estado XCUIApplication  : \(Self.describe(app.state))
        Pagina exacta           : \(trail.lastPage)
        Accion exacta           : \(trail.lastAction)
        Ultimo elemento hallado : \(trail.lastElement)
        Pantallas visibles      : \(visible.isEmpty ? "(ninguna)" : visible.joined(separator: ", "))
        ----------------------------------------
        Recorrido:
        \(trail.formatted)
        ----------------------------------------
        """

        attach(string: report, named: "diagnostico")
        attach(string: app.debugDescription, named: "jerarquia-accesibilidad")

        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "ultimo-estado-\(name).png"
        shot.lifetime = .keepAlways
        add(shot)

        return report
    }

    /// Qué identificadores `screen.*` hay realmente en pantalla. Es lo que dice si
    /// el fallo fue de la app o del selector.
    @MainActor
    private func visibleScreenIdentifiers(_ app: XCUIApplication) -> [String] {
        let known = [
            "screen.splash", "screen.onboarding", "screen.home", "screen.progress",
            "screen.sparks", "screen.profile", "screen.addMenu", "screen.activityEditor"
        ]
        return known.filter { screen(app, $0).exists }
    }

    @MainActor
    private func attach(string: String, named: String) {
        let attachment = XCTAttachment(string: string)
        attachment.name = "\(named)-\(name).txt"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private static func describe(_ state: XCUIApplication.State) -> String {
        switch state {
        case .notRunning: "notRunning - EL PROCESO TERMINO"
        case .runningBackground: "runningBackground"
        case .runningBackgroundSuspended: "runningBackgroundSuspended"
        case .runningForeground: "runningForeground"
        case .unknown: "unknown"
        @unknown default: "estado no reconocido"
        }
    }

    private struct Trail {
        private(set) var steps: [String] = []
        private(set) var lastPage = "(ninguna)"
        private(set) var lastAction = "(ninguna)"
        private(set) var lastElement = "(ninguno)"

        mutating func step(_ action: String, page: String, element: String? = nil) {
            lastAction = action
            lastPage = page
            if let element {
                lastElement = element
            }
            steps.append("  \(steps.count + 1). [\(page)] \(action)")
        }

        var formatted: String {
            steps.isEmpty ? "  (sin pasos registrados)" : steps.joined(separator: "\n")
        }
    }
}
