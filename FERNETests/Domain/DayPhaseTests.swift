import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

/// Verifica los límites horarios de los temas (MASTER_SPEC §4.5).
final class DayPhaseTests: XCTestCase {
    private let calendar = TestSupport.calendar()

    func testMorningWindowIsFiveToElevenFiftyNine() {
        XCTAssertEqual(phase(at: 5, 0), .manana)
        XCTAssertEqual(phase(at: 8, 30), .manana)
        XCTAssertEqual(phase(at: 11, 59), .manana)
    }

    func testAfternoonWindowIsTwelveToEighteenFiftyNine() {
        XCTAssertEqual(phase(at: 12, 0), .tarde)
        XCTAssertEqual(phase(at: 15, 15), .tarde)
        XCTAssertEqual(phase(at: 18, 59), .tarde)
    }

    func testNightWindowWrapsAroundMidnight() {
        XCTAssertEqual(phase(at: 19, 0), .noche)
        XCTAssertEqual(phase(at: 23, 59), .noche)
        XCTAssertEqual(phase(at: 0, 0), .noche)
        XCTAssertEqual(phase(at: 4, 59), .noche)
    }

    func testEveryPhaseHasACelestialBody() {
        // Prohibido un fondo plano sin astro (§4.5, §14.3).
        XCTAssertEqual(DayPhase.manana.celestialBody, .sun)
        XCTAssertEqual(DayPhase.tarde.celestialBody, .sun)
        XCTAssertEqual(DayPhase.noche.celestialBody, .moon)
    }

    func testGreetingsMatchApprovedCopy() {
        XCTAssertEqual(DayPhase.manana.greeting(name: "Fer"), "Buenos días, Fer ✨")
        XCTAssertEqual(DayPhase.tarde.greeting(name: "Fer"), "Buenas tardes, Fer")
        XCTAssertEqual(DayPhase.noche.greeting(name: "Fer"), "Buenas noches, Fer 🌙")
    }

    func testEveryPhaseHasAnAccessibilityDescription() {
        for phase in DayPhase.allCases {
            XCTAssertFalse(phase.accessibilityDescription.isEmpty, "\(phase) necesita descripción para VoiceOver.")
        }
    }

    func testFixedProviderAllowsDeterministicPreviews() {
        let provider = FixedDayPhaseProvider(phase: .noche)
        XCTAssertEqual(provider.currentPhase, .noche)
    }

    private func phase(at hour: Int, _ minute: Int) -> DayPhase {
        DayPhase.from(TestSupport.date(2026, 8, 6, hour, minute, calendar: calendar), calendar: calendar)
    }
}
