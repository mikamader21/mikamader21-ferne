import XCTest

/// Pruebas de humo en tiempo de ejecución.
///
/// Existen porque compilar y mantenerse en pie son cosas distintas: FERNÉ compiló
/// y aun así se cerró al terminar el onboarding. **Estas cuatro pruebas son la
/// condición para publicar `FERNE-app-now`.**
///
/// Cuando algo falla, el informe no dice "se cerró": dice en qué página estaba, qué
/// acción se ejecutó, cuál fue el último elemento encontrado y en qué estado quedó
/// `XCUIApplication`. Todo se adjunta al `.xcresult`.
///
/// Usan un almacén **real, en disco y aislado** (`-FERNERuntimeSmoke`), nunca
/// `PreviewData`: con datos sembrados la persistencia no probaría nada.
final class RuntimeSmokeUITests: XCTestCase {
    private var trail = Trail()

    /// Margen tras llegar a Inicio. El crash reportado ocurría justo en la
    /// transición, así que no basta con que la pantalla aparezca: tiene que seguir
    /// ahí unos segundos después.
    private let survivalWindow: TimeInterval = 5

    override func setUp() {
        continueAfterFailure = false
        trail = Trail()
    }

    // MARK: - A · Onboarding omitiendo notificaciones

    func testA_OnboardingWithoutNotificationsReachesHomeAndStaysAlive() {
        let app = launch(resetStore: true, skipOnboarding: false, showSplash: true)

        trail.step("esperando el splash", page: "splash")
        XCTAssertTrue(
            app.otherElements["screen.splash"].waitForExistence(timeout: 25)
                || app.otherElements["screen.onboarding"].waitForExistence(timeout: 25),
            diagnosis(app, "No apareció ni el splash ni el onboarding.")
        )

        completeOnboarding(app, notifications: .skip)
        assertReachedHomeAndSurvives(app, scenario: "A · sin notificaciones")
    }

    // MARK: - B · Onboarding activando notificaciones

    func testB_OnboardingWithNotificationsReachesHomeAndStaysAlive() {
        let app = launch(resetStore: true, skipOnboarding: false, showSplash: false)

        completeOnboarding(app, notifications: .enable)
        assertReachedHomeAndSurvives(app, scenario: "B · con notificaciones")
    }

    // MARK: - C · Recorrido funcional completo

    func testC_CreateGymConfirmItAndSeeItInProgress() {
        let app = launch(resetStore: true, skipOnboarding: false, showSplash: false)
        completeOnboarding(app, notifications: .skip)
        assertReachedHomeAndSurvives(app, scenario: "C · llegada a Inicio")

        trail.step("pulsando el botón +", page: "home")
        let fab = app.buttons["home.fab"]
        XCTAssertTrue(fab.waitForExistence(timeout: 15), diagnosis(app, "No se encontró el botón +."))
        fab.tap()

        trail.step("esperando el menú de creación", page: "addMenu")
        XCTAssertTrue(
            app.otherElements["screen.addMenu"].waitForExistence(timeout: 15),
            diagnosis(app, "El menú de creación no se abrió.")
        )

        trail.step("eligiendo la categoría Gym", page: "addMenu")
        let gym = app.buttons["addMenu.gym"]
        XCTAssertTrue(gym.waitForExistence(timeout: 10), diagnosis(app, "No se encontró la categoría Gym."))
        gym.tap()

        trail.step("esperando el editor", page: "editor")
        XCTAssertTrue(
            app.otherElements["screen.activityEditor"].waitForExistence(timeout: 15),
            diagnosis(app, "El editor de actividad no se abrió.")
        )
        assertAlive(app, "La app se cerró al abrir el editor.")

        trail.step("guardando la actividad", page: "editor")
        let save = app.buttons["editor.save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10), diagnosis(app, "No se encontró el botón Guardar."))
        save.tap()

        trail.step("comprobando que la actividad aparece en Inicio", page: "home")
        let card = app.otherElements["activity.row.gym"]
        XCTAssertTrue(card.waitForExistence(timeout: 20), diagnosis(app, "La actividad creada no apareció en Inicio."))
        assertAlive(app, "La app se cerró tras guardar la actividad.")

        trail.step("abriendo la pestaña Progreso", page: "progress")
        let progressTab = app.tabBars.buttons["Progreso"]
        XCTAssertTrue(progressTab.waitForExistence(timeout: 10), diagnosis(app, "Falta la pestaña Progreso."))
        progressTab.tap()
        XCTAssertTrue(
            app.otherElements["screen.progress"].waitForExistence(timeout: 15),
            diagnosis(app, "Progreso no se abrió.")
        )
        assertAlive(app, "La app se cerró al abrir Progreso.")

        survive(app, scenario: "C · recorrido funcional")
    }

    // MARK: - D · Persistencia entre lanzamientos

    func testD_DataSurvivesRelaunch() {
        // Primer lanzamiento: se borra el almacén aislado y se crea una actividad.
        let first = launch(resetStore: true, skipOnboarding: false, showSplash: false)
        completeOnboarding(first, notifications: .skip)
        assertReachedHomeAndSurvives(first, scenario: "D · primer lanzamiento")

        createGym(in: first)
        XCTAssertTrue(
            first.otherElements["activity.row.gym"].waitForExistence(timeout: 20),
            diagnosis(first, "La actividad no llegó a crearse en el primer lanzamiento.")
        )
        first.terminate()

        // Segundo lanzamiento: **mismo almacén**, sin borrar. Es lo único que
        // demuestra que los datos sobreviven.
        trail.step("relanzando sin borrar el almacén", page: "relaunch")
        let second = launch(resetStore: false, skipOnboarding: false, showSplash: false)

        trail.step("comprobando que NO reaparece el onboarding", page: "home")
        XCTAssertTrue(
            second.otherElements["screen.home"].waitForExistence(timeout: 25),
            diagnosis(second, "Tras relanzar no se llegó a Inicio.")
        )
        XCTAssertFalse(
            second.otherElements["screen.onboarding"].exists,
            diagnosis(second, "El onboarding reapareció: no se guardó que ya se completó.")
        )

        trail.step("comprobando que la actividad sigue guardada", page: "home")
        XCTAssertTrue(
            second.otherElements["activity.row.gym"].waitForExistence(timeout: 20),
            diagnosis(second, "La actividad no sobrevivió al relanzamiento.")
        )

        survive(second, scenario: "D · persistencia")
    }

    // MARK: - Recorrido del onboarding

    private enum NotificationChoice { case enable, skip }

    /// Avanza las siete páginas (0…6).
    private func completeOnboarding(_ app: XCUIApplication, notifications: NotificationChoice) {
        trail.step("esperando el onboarding", page: "onboarding")
        XCTAssertTrue(
            app.otherElements["screen.onboarding"].waitForExistence(timeout: 30),
            diagnosis(app, "El onboarding no apareció en una instalación limpia.")
        )

        for page in 0 ... 6 {
            trail.step("página \(page)", page: "onboarding.\(page)")
            assertAlive(app, "La app se cerró al mostrar la página \(page) del onboarding.")

            if page == 5 {
                resolveNotifications(app, choice: notifications)
            }

            let identifier = page == 6 ? "onboarding.finish" : "onboarding.advance"
            let button = app.buttons[identifier]
            guard button.waitForExistence(timeout: 15) else {
                XCTFail(diagnosis(app, "No apareció '\(identifier)' en la página \(page)."))
                return
            }
            trail.step("pulsando '\(identifier)'", page: "onboarding.\(page)", element: identifier)
            button.tap()
            assertAlive(app, "La app se cerró al pulsar '\(identifier)' en la página \(page).")
        }
    }

    private func resolveNotifications(_ app: XCUIApplication, choice: NotificationChoice) {
        switch choice {
        case .skip:
            let skip = app.buttons["onboarding.skipNotifications"]
            if skip.waitForExistence(timeout: 10) {
                trail.step("pulsando 'Ahora no'", page: "onboarding.5", element: "onboarding.skipNotifications")
                skip.tap()
                assertAlive(app, "La app se cerró al omitir las notificaciones.")
            }
        case .enable:
            let enable = app.buttons["onboarding.enableNotifications"]
            if enable.waitForExistence(timeout: 10) {
                trail.step("pulsando 'Activar recordatorios'", page: "onboarding.5", element: "onboarding.enableNotifications")
                enable.tap()
                resolveSystemPermissionDialog(app)
                assertAlive(app, "La app se cerró al pedir el permiso de notificaciones.")
            }
        }
    }

    /// Resuelve el diálogo de iOS acepte o rechace: ambos caminos deben dejar la app
    /// en pie. Si el permiso se deniega, FERNÉ tiene que seguir funcionando.
    private func resolveSystemPermissionDialog(_ app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let candidates = ["Permitir", "Allow", "No permitir", "Don't Allow", "Don’t Allow"]

        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            for label in candidates {
                let button = springboard.buttons[label]
                if button.exists, button.isHittable {
                    trail.step("respondiendo al diálogo del sistema: '\(label)'", page: "onboarding.5", element: label)
                    button.tap()
                    _ = app.wait(for: .runningForeground, timeout: 8)
                    return
                }
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        trail.step("el diálogo del sistema no apareció", page: "onboarding.5")
    }

    private func createGym(in app: XCUIApplication) {
        trail.step("creando actividad Gym", page: "home")
        let fab = app.buttons["home.fab"]
        guard fab.waitForExistence(timeout: 15) else {
            XCTFail(diagnosis(app, "No se encontró el botón + para crear."))
            return
        }
        fab.tap()
        let gym = app.buttons["addMenu.gym"]
        guard gym.waitForExistence(timeout: 15) else {
            XCTFail(diagnosis(app, "No se encontró la categoría Gym."))
            return
        }
        gym.tap()
        let save = app.buttons["editor.save"]
        guard save.waitForExistence(timeout: 15) else {
            XCTFail(diagnosis(app, "No se encontró el botón Guardar."))
            return
        }
        save.tap()
    }

    // MARK: - Comprobaciones

    private func assertReachedHomeAndSurvives(_ app: XCUIApplication, scenario: String) {
        trail.step("esperando Inicio", page: "home")
        XCTAssertTrue(
            app.otherElements["screen.home"].waitForExistence(timeout: 25),
            diagnosis(app, "\(scenario): no se llegó a Inicio.")
        )
        survive(app, scenario: scenario)
    }

    /// La pantalla aparece y **sigue ahí** pasados unos segundos.
    /// El crash reportado ocurría en la transición: comprobar solo la aparición
    /// habría dado un falso verde.
    private func survive(_ app: XCUIApplication, scenario: String) {
        assertAlive(app, "\(scenario): la app no estaba en primer plano.")
        trail.step("esperando \(Int(survivalWindow)) s para confirmar que sigue viva", page: "home")
        Thread.sleep(forTimeInterval: survivalWindow)
        assertAlive(app, "\(scenario): la app se cerró en los \(Int(survivalWindow)) s siguientes.")
    }

    private func launch(resetStore: Bool, skipOnboarding: Bool, showSplash: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-FERNERuntimeSmoke",
            "-FERNESkipSplash", showSplash ? "0" : "1",
            "-FERNESkipOnboarding", skipOnboarding ? "1" : "0"
        ]
        if resetStore {
            app.launchArguments.append("-FERNEResetStore")
        }
        app.launchEnvironment["FERNE_RUNTIME_SMOKE"] = "1"
        app.launch()
        return app
    }

    // MARK: - Diagnóstico

    private func assertAlive(_ app: XCUIApplication, _ message: String) {
        guard app.state != .runningForeground else { return }
        XCTFail(diagnosis(app, message))
    }

    /// Informe completo del punto de fallo. Se adjunta al `.xcresult`.
    private func diagnosis(_ app: XCUIApplication, _ message: String) -> String {
        let report = """
        ════════════════════════════════════════
        \(message)
        ────────────────────────────────────────
        Estado de XCUIApplication : \(Self.describe(app.state))
        Página exacta             : \(trail.lastPage)
        Acción exacta             : \(trail.lastAction)
        Último elemento hallado   : \(trail.lastElement)
        ────────────────────────────────────────
        Recorrido completo:
        \(trail.formatted)
        ════════════════════════════════════════
        """

        attach(string: report, named: "diagnostico")
        attach(string: app.debugDescription, named: "jerarquia-accesibilidad")

        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "ultimo-estado-\(name).png"
        shot.lifetime = .keepAlways
        add(shot)

        return report
    }

    private func attach(string: String, named: String) {
        let attachment = XCTAttachment(string: string)
        attachment.name = "\(named)-\(name).txt"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private static func describe(_ state: XCUIApplication.State) -> String {
        switch state {
        case .notRunning: "notRunning — EL PROCESO TERMINÓ"
        case .runningBackground: "runningBackground"
        case .runningBackgroundSuspended: "runningBackgroundSuspended"
        case .runningForeground: "runningForeground"
        case .unknown: "unknown"
        @unknown default: "estado no reconocido"
        }
    }

    /// Registro del recorrido. Sin esto, un fallo solo diría "no existe el elemento".
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
