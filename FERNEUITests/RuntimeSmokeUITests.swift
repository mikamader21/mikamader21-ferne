import XCTest

/// Pruebas de humo en tiempo de ejecucion.
///
/// Textos sin acentos a proposito: el log de GitHub Actions los rompia.
///
/// **Por que esta version no busca pantallas.** El diagnostico por `simctl`
/// (run 31158125780) demostro que la app arranca, se mantiene viva con el mismo
/// PID a los 5 y 15 s, y muestra la primera pagina del onboarding. Lo que fallaba
/// era XCTest buscando anclas `screen.*`: SwiftUI no publica esos contenedores
/// como elementos consultables, y `.accessibilityElement(children: .contain)`
/// tampoco lo resolvio.
///
/// Por eso todo el recorrido se conduce por **controles reales** —botones, campos
/// e interruptores— que la automatizacion siempre ve. Cero selectores de
/// contenedor.
///
/// Cada escenario usa su propio almacen (`FERNE_RUNTIME_TEST_ID`). A, B y C
/// arrancan limpios; D comparte almacen entre sus dos lanzamientos.
final class RuntimeSmokeUITests: XCTestCase {
    private var trail = Trail()
    private var currentTestID = ""
    private var currentReset = true

    /// Una sola espera inicial larga; las transiciones posteriores son cortas.
    private enum Timeout {
        /// Primer control tras `launch()`. Incluye arranque en frio.
        static let launch: TimeInterval = 30
        /// Cambio de pagina o de pantalla con la app ya viva.
        static let transition: TimeInterval = 15
        /// Control dentro de una pantalla ya presente.
        static let control: TimeInterval = 10
        /// Dialogo del sistema, que puede no llegar a aparecer.
        static let systemDialog: TimeInterval = 8
    }

    /// Control que identifica inequivocamente cada pagina del onboarding.
    ///
    /// | Pagina | Control | Que confirma |
    /// |---|---|---|
    /// | 0 | `onboarding.nameField` | campo del nombre |
    /// | 1 | `onboarding.category.gym` | tarjetas de categoria |
    /// | 2 | `onboarding.wakeReminder` | interruptor de despertar |
    /// | 3 | `onboarding.meal.breakfast` | interruptor de desayuno |
    /// | 4 | `onboarding.tone.dailyMessage` | interruptor de mensajes |
    /// | 5 | `onboarding.skipNotifications` | pagina de recordatorios |
    /// | 6 | `onboarding.ready` | pagina final |
    private static let pageAnchors: [(page: Int, identifier: String, kind: ElementKind)] = [
        (0, "onboarding.nameField", .textField),
        (1, "onboarding.category.gym", .button),
        (2, "onboarding.wakeReminder", .switchControl),
        (3, "onboarding.meal.breakfast", .switchControl),
        (4, "onboarding.tone.dailyMessage", .switchControl),
        (5, "onboarding.skipNotifications", .button),
        (6, "onboarding.ready", .any)
    ]

    private enum ElementKind { case button, textField, switchControl, any }

    override func setUp() {
        continueAfterFailure = false
        trail = Trail()
    }

    // MARK: - A · Onboarding omitiendo notificaciones

    @MainActor
    func testA_OnboardingWithoutNotificationsReachesHome() {
        let app = launch(testID: "A", resetStore: true)
        completeOnboarding(app, notifications: .skip)
        assertHomeIsUsable(app, scenario: "A · sin notificaciones")
        assertStillAliveAfterSettling(app, scenario: "A")
    }

    // MARK: - B · Onboarding activando notificaciones

    @MainActor
    func testB_OnboardingWithNotificationsReachesHome() {
        let app = launch(testID: "B", resetStore: true)
        completeOnboarding(app, notifications: .enable)
        assertHomeIsUsable(app, scenario: "B · con notificaciones")
        assertStillAliveAfterSettling(app, scenario: "B")
    }

    // MARK: - C · Crear Gym y verlo en Progreso

    @MainActor
    func testC_CreateGymAndSeeItInProgress() {
        let app = launch(testID: "C", resetStore: true)
        completeOnboarding(app, notifications: .skip)
        assertHomeIsUsable(app, scenario: "C · llegada a Inicio")

        createGym(in: app)

        trail.step("comprobando la fila creada", page: "home")
        let rowShown = app.descendants(matching: .any)["activity.row.gym"]
            .waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(rowShown, diagnosis(app, "La actividad creada no aparecio en Inicio."))

        trail.step("abriendo Progreso", page: "progress")
        tapProgressTab(app)

        let summaryShown = app.descendants(matching: .any)["progress.summary"]
            .waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(summaryShown, diagnosis(app, "Progreso no mostro su resumen."))
        assertAlive(app, "C: la app se cerro al abrir Progreso.")
    }

    // MARK: - D · Persistencia entre lanzamientos

    @MainActor
    func testD_DataSurvivesRelaunch() {
        let first = launch(testID: "D", resetStore: true)
        completeOnboarding(first, notifications: .skip)
        assertHomeIsUsable(first, scenario: "D · primer lanzamiento")

        createGym(in: first)
        let created = first.descendants(matching: .any)["activity.row.gym"]
            .waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(created, diagnosis(first, "La actividad no se creo en el primer lanzamiento."))
        first.terminate()

        // Segundo lanzamiento: MISMO testID, sin reset.
        trail.step("relanzando con el mismo almacen", page: "relaunch")
        let second = launch(testID: "D", resetStore: false)

        trail.step("esperando Inicio sin pasar por el onboarding", page: "home")
        let addShown = second.buttons["home.add"].waitForExistence(timeout: Timeout.launch)
        XCTAssertTrue(addShown, diagnosis(second, "Tras relanzar no aparecio el boton + de Inicio."))

        let onboardingBack = second.textFields["onboarding.nameField"].exists
        XCTAssertFalse(onboardingBack, diagnosis(second, "El onboarding reaparecio tras relanzar."))

        let survived = second.descendants(matching: .any)["activity.row.gym"]
            .waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(survived, diagnosis(second, "La actividad no sobrevivio al relanzamiento."))
        assertStillAliveAfterSettling(second, scenario: "D")
    }

    // MARK: - Onboarding

    private enum NotificationChoice { case enable, skip }

    /// Recorre las siete paginas esperando el control real de cada una.
    /// Sin sleeps y sin suponer indices: cada paso se confirma con un elemento.
    @MainActor
    private func completeOnboarding(_ app: XCUIApplication, notifications: NotificationChoice) {
        for (index, anchor) in Self.pageAnchors.enumerated() {
            let timeout = index == 0 ? Timeout.launch : Timeout.transition
            trail.step("esperando '\(anchor.identifier)'", page: "onboarding.\(anchor.page)")

            let element = element(app, anchor.identifier, kind: anchor.kind)
            let ready = element.waitForExistence(timeout: timeout)
            guard ready else {
                XCTFail(diagnosis(app, "No aparecio '\(anchor.identifier)' en la pagina \(anchor.page)."))
                return
            }
            trail.step("pagina \(anchor.page) confirmada", page: "onboarding.\(anchor.page)", element: anchor.identifier)
            assertAlive(app, "La app se cerro en la pagina \(anchor.page).")

            if anchor.page == 5 {
                resolveNotifications(app, choice: notifications)
            }

            let advance = app.buttons["onboarding.continue"]
            let advanceReady = advance.waitForExistence(timeout: Timeout.control)
            guard advanceReady else {
                XCTFail(diagnosis(app, "No aparecio 'onboarding.continue' en la pagina \(anchor.page)."))
                return
            }
            trail.step("pulsando 'onboarding.continue'", page: "onboarding.\(anchor.page)", element: "onboarding.continue")
            advance.tap()
            assertAlive(app, "La app se cerro al avanzar desde la pagina \(anchor.page).")
        }
    }

    @MainActor
    private func resolveNotifications(_ app: XCUIApplication, choice: NotificationChoice) {
        let identifier = choice == .skip ? "onboarding.skipNotifications" : "onboarding.enableNotifications"
        let button = app.buttons[identifier]
        let ready = button.waitForExistence(timeout: Timeout.control)
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
                    _ = app.wait(for: .runningForeground, timeout: Timeout.control)
                    return
                }
            }
            _ = springboard.buttons.firstMatch.waitForExistence(timeout: 1)
        }
        trail.step("el dialogo del sistema no aparecio", page: "onboarding.5")
    }

    // MARK: - Creacion de actividad

    @MainActor
    private func createGym(in app: XCUIApplication) {
        trail.step("pulsando 'home.add'", page: "home", element: "home.add")
        let add = app.buttons["home.add"]
        let addReady = add.waitForExistence(timeout: Timeout.control)
        XCTAssertTrue(addReady, diagnosis(app, "No se encontro 'home.add'."))
        add.tap()

        trail.step("eligiendo 'addMenu.gym'", page: "addMenu", element: "addMenu.gym")
        let gym = app.buttons["addMenu.gym"]
        let gymReady = gym.waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(gymReady, diagnosis(app, "No se encontro 'addMenu.gym'."))
        gym.tap()

        trail.step("esperando el formulario", page: "editor", element: "activity.title")
        let title = app.textFields["activity.title"]
        let titleReady = title.waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(titleReady, diagnosis(app, "No aparecio 'activity.title'."))

        trail.step("guardando", page: "editor", element: "activity.save")
        let save = app.buttons["activity.save"]
        let saveReady = save.waitForExistence(timeout: Timeout.control)
        XCTAssertTrue(saveReady, diagnosis(app, "No se encontro 'activity.save'."))
        save.tap()
    }

    // MARK: - Comprobaciones

    /// Inicio listo: boton + **y** pestaña Progreso **y** proceso vivo.
    /// Los tres a la vez; estar en primer plano por si solo no dice nada.
    @MainActor
    private func assertHomeIsUsable(_ app: XCUIApplication, scenario: String) {
        trail.step("esperando 'home.add'", page: "home", element: "home.add")
        let addShown = app.buttons["home.add"].waitForExistence(timeout: Timeout.transition)
        XCTAssertTrue(addShown, diagnosis(app, "\(scenario): no aparecio el boton + de Inicio."))

        let progressReachable = progressTab(app).waitForExistence(timeout: Timeout.control)
        XCTAssertTrue(progressReachable, diagnosis(app, "\(scenario): la pestaña Progreso no esta disponible."))

        assertAlive(app, "\(scenario): la app no estaba en primer plano.")
    }

    /// El proceso sigue vivo despues de asentarse. Sin sleep fijo: se espera a un
    /// control que debe seguir existiendo y luego se comprueba el estado.
    @MainActor
    private func assertStillAliveAfterSettling(_ app: XCUIApplication, scenario: String) {
        trail.step("comprobando que Inicio sigue en pie", page: "home")
        let stillThere = app.buttons["home.add"].waitForExistence(timeout: Timeout.control)
        XCTAssertTrue(stillThere, diagnosis(app, "\(scenario): Inicio dejo de estar disponible."))
        assertAlive(app, "\(scenario): la app se cerro despues de llegar a Inicio.")
    }

    /// La pestaña Progreso por identificador; si no lo publica, por su etiqueta.
    @MainActor
    private func progressTab(_ app: XCUIApplication) -> XCUIElement {
        let byIdentifier = app.tabBars.buttons["tab.progress"]
        return byIdentifier.exists ? byIdentifier : app.tabBars.buttons["Progreso"]
    }

    @MainActor
    private func tapProgressTab(_ app: XCUIApplication) {
        let tab = progressTab(app)
        let ready = tab.waitForExistence(timeout: Timeout.control)
        XCTAssertTrue(ready, diagnosis(app, "No se encontro la pestaña Progreso."))
        tab.tap()
    }

    @MainActor
    private func element(_ app: XCUIApplication, _ identifier: String, kind: ElementKind) -> XCUIElement {
        switch kind {
        case .button: app.buttons[identifier]
        case .textField: app.textFields[identifier]
        case .switchControl: app.switches[identifier]
        case .any: app.descendants(matching: .any)[identifier]
        }
    }

    // MARK: - Lanzamiento

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

    /// Informe completo. Ya no se limita a `screen.*`: sabemos que no existen.
    /// Enumera los controles reales que SI hay, que es lo que permite corregir.
    @MainActor
    private func diagnosis(_ app: XCUIApplication, _ message: String) -> String {
        let report = """
        ----------------------------------------
        \(message)
        ----------------------------------------
        FERNE_RUNTIME_TEST_ID   : \(currentTestID)
        Almacen                 : \(currentReset ? "reset (limpio)" : "reutilizado (sin borrar)")
        Estado XCUIApplication  : \(Self.describe(app.state))
        Pagina exacta           : \(trail.lastPage)
        Accion exacta           : \(trail.lastAction)
        Ultimo elemento buscado : \(trail.lastElement)
        ----------------------------------------
        Botones (\(app.buttons.count)):
        \(inventory(app.buttons))
        ----------------------------------------
        Campos de texto (\(app.textFields.count)):
        \(inventory(app.textFields))
        ----------------------------------------
        Interruptores (\(app.switches.count)):
        \(inventory(app.switches))
        ----------------------------------------
        Elementos con identificador conocido:
        \(knownIdentifiers(app))
        ----------------------------------------
        Recorrido:
        \(trail.formatted)
        ----------------------------------------
        """

        // El volcado completo va tambien al log, no solo al adjunto: en Actions es
        // lo primero que se lee.
        print(report)
        print("--- app.debugDescription ---")
        print(app.debugDescription)

        attach(string: report, named: "diagnostico")
        attach(string: app.debugDescription, named: "jerarquia-accesibilidad")

        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "ultimo-estado-\(name).png"
        shot.lifetime = .keepAlways
        add(shot)

        return report
    }

    /// Identificador y etiqueta de cada elemento de una consulta.
    @MainActor
    private func inventory(_ query: XCUIElementQuery) -> String {
        let elements = query.allElementsBoundByIndex.prefix(40)
        guard !elements.isEmpty else { return "  (ninguno)" }
        return elements.map { element in
            let identifier = element.identifier.isEmpty ? "(sin id)" : element.identifier
            let label = element.label.isEmpty ? "(sin label)" : element.label
            return "  id='\(identifier)' label='\(label)'"
        }.joined(separator: "\n")
    }

    /// Cuales de los identificadores que usa el smoke existen ahora mismo.
    @MainActor
    private func knownIdentifiers(_ app: XCUIApplication) -> String {
        let prefixes = ["onboarding.", "home.", "activity.", "tab.", "progress."]
        let found = app.descendants(matching: .any)
            .allElementsBoundByIndex
            .prefix(200)
            .map(\.identifier)
            .filter { identifier in prefixes.contains { identifier.hasPrefix($0) } }
        let unique = Array(Set(found)).sorted()
        return unique.isEmpty ? "  (ninguno)" : unique.map { "  \($0)" }.joined(separator: "\n")
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
