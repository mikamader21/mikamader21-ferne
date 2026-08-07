import XCTest

/// Smoke test de Fase 0: la app arranca, el splash termina y la barra de pestañas
/// muestra las cuatro secciones de MASTER_SPEC §5.
///
/// Los métodos van marcados `@MainActor` porque en Xcode 16.4 toda la API de
/// XCUIAutomation está aislada al actor principal. El resultado de cada consulta se
/// evalúa **antes** del assert: dentro de la autoclosure de `XCTAssertTrue` el
/// compilador pierde el aislamiento.
final class SmokeUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsTheFourTabs() {
        let app = XCUIApplication()
        app.launch()

        // El splash dura 2–3 s; damos margen.
        let tabBarShown = app.tabBars.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(tabBarShown, "La barra de pestañas debe aparecer tras el splash.")

        for title in ["Inicio", "Progreso", "Destellos", "Perfil"] {
            let tabExists = app.tabBars.buttons[title].exists
            XCTAssertTrue(tabExists, "Falta la pestaña \(title).")
        }
    }

    @MainActor
    func testEachTabOpensWithoutCrashing() {
        let app = XCUIApplication()
        app.launch()

        let tabBarShown = app.tabBars.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(tabBarShown)

        for title in ["Progreso", "Destellos", "Perfil", "Inicio"] {
            app.tabBars.buttons[title].tap()
            let isSelected = app.tabBars.buttons[title].isSelected
            XCTAssertTrue(isSelected)
        }
    }
}
