import XCTest

/// Smoke test de Fase 0: la app arranca, el splash termina y la barra de pestañas
/// muestra las cuatro secciones de MASTER_SPEC §5.
final class SmokeUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsTheFourTabs() {
        let app = XCUIApplication()
        app.launch()

        // El splash dura 2–3 s; damos margen.
        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 10),
            "La barra de pestañas debe aparecer tras el splash."
        )

        for title in ["Inicio", "Progreso", "Destellos", "Perfil"] {
            XCTAssertTrue(app.tabBars.buttons[title].exists, "Falta la pestaña \(title).")
        }
    }

    func testEachTabOpensWithoutCrashing() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))

        for title in ["Progreso", "Destellos", "Perfil", "Inicio"] {
            app.tabBars.buttons[title].tap()
            XCTAssertTrue(app.tabBars.buttons[title].isSelected)
        }
    }
}
