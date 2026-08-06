import XCTest

/// Capturas automáticas para la QA visual (MASTER_SPEC §14.3).
///
/// Desde Windows no hay simulador local: estas capturas, generadas por el runner
/// macOS, son la única forma de ver FERNÉ. Por eso deben ser **deterministas**:
/// la franja horaria, los datos y la fecha se fijan por argumento de lanzamiento,
/// nunca por el reloj del simulador.
///
/// El **tamaño de dispositivo** no se controla desde aquí: lo aporta la matriz de
/// simuladores del workflow (`.github/workflows/ios-ci.yml`).
final class ScreenshotTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Escenarios

    /// Las tres franjas horarias, con datos mixtos. Cubre sol, luna y cielo ciruela.
    func testCapturaFranjasHorarias() {
        for phase in ["manana", "tarde", "noche"] {
            capture(
                name: "home-\(phase)",
                phase: phase,
                screen: "screen.home"
            )
        }
    }

    /// Estado vacío: FERNÉ nunca muestra una pantalla en blanco.
    func testCapturaEstadoVacio() {
        capture(name: "home-vacio-manana", phase: "manana", fixture: "vacio", screen: "screen.home")
        capture(name: "home-vacio-noche", phase: "noche", fixture: "vacio", screen: "screen.home")
    }

    /// Día completo: todas las actividades marcadas.
    func testCapturaDiaCompleto() {
        capture(name: "home-completo-tarde", phase: "tarde", fixture: "completo", screen: "screen.home")
    }

    /// Dynamic Type en tamaño de accesibilidad grande (§14.3).
    func testCapturaDynamicTypeGrande() {
        capture(
            name: "home-dynamictype-XXL-manana",
            phase: "manana",
            screen: "screen.home",
            contentSize: "UICTContentSizeCategoryAccessibilityL"
        )
        capture(
            name: "progress-dynamictype-XXL-noche",
            phase: "noche",
            screen: "screen.progress",
            tab: "Progreso",
            contentSize: "UICTContentSizeCategoryAccessibilityL"
        )
    }

    /// Reduce Motion: la escena debe conservarse, solo se detiene el movimiento.
    func testCapturaReduceMotion() {
        capture(name: "home-reducemotion-noche", phase: "noche", screen: "screen.home", reduceMotion: true)
    }

    /// Splash cinematográfico en sus dos variantes.
    func testCapturaSplash() {
        for phase in ["manana", "noche"] {
            let app = launch(phase: phase, skipSplash: false)
            XCTAssertTrue(
                app.otherElements["screen.splash"].waitForExistence(timeout: 5),
                "El splash debe aparecer en \(phase)."
            )
            attach(app.screenshot(), named: "splash-\(phase)")
            app.terminate()
        }
    }

    /// Las cuatro pestañas, de día y de noche.
    func testCapturaTodasLasPestanas() {
        let tabs = [
            ("Inicio", "screen.home"),
            ("Progreso", "screen.progress"),
            ("Destellos", "screen.sparks"),
            ("Perfil", "screen.profile"),
        ]
        for phase in ["manana", "noche"] {
            let app = launch(phase: phase)
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
            for (title, identifier) in tabs {
                app.tabBars.buttons[title].tap()
                _ = app.otherElements[identifier].waitForExistence(timeout: 5)
                attach(app.screenshot(), named: "\(title.lowercased())-\(phase)")
            }
            app.terminate()
        }
    }

    // MARK: - Utilidades

    private func launch(
        phase: String,
        fixture: String = "mixto",
        skipSplash: Bool = true,
        reduceMotion: Bool = false,
        contentSize: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-FERNEUITest", "1",
            "-FERNEPhase", phase,
            "-FERNEFixture", fixture,
            "-FERNESkipSplash", skipSplash ? "1" : "0",
            "-FERNEReduceMotion", reduceMotion ? "1" : "0",
        ]
        if let contentSize {
            // Argumento estándar de UIKit: cambia el tamaño de texto sin tocar Ajustes.
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize]
        }
        app.launchEnvironment["FERNE_UITEST"] = "1"
        app.launch()
        return app
    }

    private func capture(
        name: String,
        phase: String,
        fixture: String = "mixto",
        screen: String,
        tab: String? = nil,
        reduceMotion: Bool = false,
        contentSize: String? = nil
    ) {
        let app = launch(phase: phase, fixture: fixture, reduceMotion: reduceMotion, contentSize: contentSize)
        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 15),
            "La app no llegó a la barra de pestañas para '\(name)'."
        )
        if let tab {
            app.tabBars.buttons[tab].tap()
        }
        XCTAssertTrue(
            app.otherElements[screen].waitForExistence(timeout: 8),
            "No apareció '\(screen)' para '\(name)'."
        )
        // Margen para que la escena termine su transición de entrada.
        Thread.sleep(forTimeInterval: 1.0)
        attach(app.screenshot(), named: name)
        app.terminate()
    }

    private func attach(_ screenshot: XCUIScreenshot, named name: String) {
        let device = deviceSlug()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(device)__\(name).png"
        // `.keepAlways` es imprescindible: sin él, el adjunto se descarta cuando
        // el test pasa y el artifact de capturas llegaría vacío.
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Nombre de dispositivo normalizado, para que la galería agrupe por tamaño.
    private func deviceSlug() -> String {
        let name = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "device"
        return name
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .lowercased()
    }
}
