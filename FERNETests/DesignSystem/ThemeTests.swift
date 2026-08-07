import SwiftUI
import XCTest
@testable import FERNE

/// Pruebas del sistema de temas. Requieren SwiftUI, por lo que solo corren en Xcode
/// (`make test`), no en `Scripts/verify-logic.sh`.
final class ThemeTests: XCTestCase {
    func testEveryPhaseHasATheme() {
        for phase in DayPhase.allCases {
            let theme = FerneTheme.theme(for: phase)
            XCTAssertEqual(theme.phase, phase)
            XCTAssertFalse(theme.skyColors.isEmpty, "Toda escena necesita un degradado de cielo.")
        }
    }

    func testNightThemeShowsStarsAndMoon() {
        let night = FerneTheme.noche
        XCTAssertEqual(night.celestialBody, .moon)
        XCTAssertGreaterThan(night.starOpacity, 0)
    }

    func testDayThemesShowSunAndNoStars() {
        for theme in [FerneTheme.manana, FerneTheme.tarde] {
            XCTAssertEqual(theme.celestialBody, .sun)
            XCTAssertEqual(theme.starOpacity, 0)
        }
    }

    func testThemeControllerFollowsItsProvider() {
        let controller = ThemeController.preview(.noche)
        XCTAssertEqual(controller.phase, .noche)
        XCTAssertEqual(controller.theme.celestialBody, .moon)
        XCTAssertEqual(controller.greeting(for: "Fer"), "Buenas noches, Fer 🌙")
    }

    func testPhaseTransitionStaysInsideItsRange() {
        XCTAssertTrue(
            FerneMotion.phaseRange.contains(FerneMotion.phaseTransition),
            "La transición día/noche debe durar entre 0.8 y 1.2 s."
        )
    }

    func testCardAnimationStaysInsideTheApprovedRange() {
        // Rango acordado para tarjetas: 220–320 ms.
        XCTAssertTrue(FerneMotion.uiRange.contains(0.26))
    }

    func testStaggerIsSmallEnoughToFeelImmediate() {
        XCTAssertLessThanOrEqual(FerneMotion.staggerStep, 0.06)
    }

    func testDayThemesUseDarkTextAndNightUsesLightText() {
        // Es el fallo que corrige el trabajo: texto claro sobre el amanecer se perdía.
        XCTAssertFalse(FerneTheme.manana.hasDarkAtmosphere)
        XCTAssertFalse(FerneTheme.tarde.hasDarkAtmosphere)
        XCTAssertTrue(FerneTheme.noche.hasDarkAtmosphere)

        XCTAssertTrue(FerneTheme.manana.needsTextScrim, "Sobre el amanecer hace falta velo.")
        XCTAssertTrue(FerneTheme.tarde.needsTextScrim)
        XCTAssertFalse(FerneTheme.noche.needsTextScrim, "El cielo nocturno ya es oscuro.")
    }

    func testMotionDurationsStayInsideTheApprovedRanges() {
        // §4.6: UI 200–450 ms, escenas 2–3 s.
        XCTAssertTrue(FerneMotion.uiRange.contains(FerneMotion.quick))
        XCTAssertTrue(FerneMotion.uiRange.contains(FerneMotion.standard))
        XCTAssertTrue(FerneMotion.uiRange.contains(FerneMotion.expressive))
        XCTAssertTrue(FerneMotion.sceneRange.contains(FerneMotion.splash))
    }

    func testReduceMotionRemovesAnimation() {
        XCTAssertNil(FerneMotion.respectingReduceMotion(FerneMotion.ease, reduceMotion: true))
        XCTAssertNotNil(FerneMotion.respectingReduceMotion(FerneMotion.ease, reduceMotion: false))
    }

    func testTapTargetMeetsAccessibilityMinimum() {
        XCTAssertGreaterThanOrEqual(FerneSize.minimumTapTarget, 44)
    }

    func testCardRadiusStaysInApprovedRange() {
        XCTAssertTrue((20.0 ... 24.0).contains(FerneRadius.card))
        XCTAssertTrue((20.0 ... 24.0).contains(FerneRadius.cardLarge))
    }

    func testParticleDensityStaysLow() {
        XCTAssertLessThanOrEqual(FerneMotion.particleCount, 20, "Las partículas deben ser de baja densidad.")
    }

    func testSoundLibraryDeclaresTheSixApprovedSounds() {
        XCTAssertEqual(
            SoundLibrary.all.map(\.displayName),
            ["Amanecer", "Campanita", "Destello", "Flor", "Luna", "Sueño"]
        )
    }
}
