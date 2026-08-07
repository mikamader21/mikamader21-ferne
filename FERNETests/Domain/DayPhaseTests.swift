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

    func testAfternoonWindowIsTwelveToSeventeenFiftyNine() {
        XCTAssertEqual(phase(at: 12, 0), .tarde)
        XCTAssertEqual(phase(at: 15, 15), .tarde)
        XCTAssertEqual(phase(at: 17, 59), .tarde)
    }

    func testNightWindowWrapsAroundMidnight() {
        XCTAssertEqual(phase(at: 18, 0), .noche, "A las 18:00 en punto empieza la noche.")
        XCTAssertEqual(phase(at: 23, 59), .noche)
        XCTAssertEqual(phase(at: 0, 0), .noche)
        XCTAssertEqual(phase(at: 4, 59), .noche)
    }

    /// Los seis límites exactos, uno por uno.
    func testExactBoundaries() {
        XCTAssertEqual(phase(at: 4, 59), .noche)
        XCTAssertEqual(phase(at: 5, 0), .manana)
        XCTAssertEqual(phase(at: 11, 59), .manana)
        XCTAssertEqual(phase(at: 12, 0), .tarde)
        XCTAssertEqual(phase(at: 17, 59), .tarde)
        XCTAssertEqual(phase(at: 18, 0), .noche)
        XCTAssertEqual(phase(at: 23, 59), .noche)
    }

    /// El mismo instante puede caer en franjas distintas según la zona horaria.
    func testPhaseFollowsTheLocalTimeZone() {
        let bogota = TestSupport.calendar(timeZoneID: "America/Bogota")
        let madrid = TestSupport.calendar(timeZoneID: "Europe/Madrid")

        // 14:00 en Bogotá = 21:00 en Madrid.
        let instant = TestSupport.date(2026, 8, 6, 14, 0, calendar: bogota)

        XCTAssertEqual(DayPhase.from(instant, calendar: bogota), .tarde)
        XCTAssertEqual(DayPhase.from(instant, calendar: madrid), .noche)
    }

    /// La siguiente frontera se calcula para poder cambiar la escena sin sondear.
    func testNextTransitionFindsTheUpcomingBoundary() {
        let calendar = TestSupport.calendar()
        func nextHour(from hour: Int) -> Int? {
            let date = TestSupport.date(2026, 8, 6, hour, 30, calendar: calendar)
            guard let next = DayPhase.nextTransition(after: date, calendar: calendar) else { return nil }
            return calendar.component(.hour, from: next)
        }

        XCTAssertEqual(nextHour(from: 2), 5)
        XCTAssertEqual(nextHour(from: 8), 12)
        XCTAssertEqual(nextHour(from: 14), 18)
        XCTAssertEqual(nextHour(from: 20), 5, "Pasadas las 18:00, la siguiente es a las 05:00 del día siguiente.")
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
        // Sin emoji: la escena ya muestra la luna, repetirla en el texto era redundante.
        XCTAssertEqual(DayPhase.noche.greeting(name: "Fer"), "Buenas noches, Fer")
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
