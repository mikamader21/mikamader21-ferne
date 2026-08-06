import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

/// Cubre los ocho casos obligatorios de MASTER_SPEC §9.4.
final class ScoreEngineTests: XCTestCase {
    private let calendar = TestSupport.calendar()
    private var engine: ScoreEngine {
        ScoreEngine(calendar: calendar)
    }

    /// §9.4 · Caso 1 — Día sin actividades
    func testDayWithoutActivitiesHasNoDataAndDoesNotScoreZeroAsFailure() {
        let day = TestSupport.date(2026, 8, 6)
        let score = engine.dailyScore(for: day, activities: [])

        XCTAssertEqual(score.evaluableCount, 0)
        XCTAssertFalse(score.hasData, "Un día sin actividades no tiene datos; no es un 0% de cumplimiento.")
        XCTAssertEqual(score.rawPercentage, 0, accuracy: 0.0001)
    }

    /// §9.4 · Caso 2 — Todas completadas
    func testAllCompletedGivesOneHundred() {
        let day = TestSupport.date(2026, 8, 6)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 13), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 20), status: .completada),
        ]
        let score = engine.dailyScore(for: day, activities: activities)

        XCTAssertEqual(score.evaluableCount, 3)
        XCTAssertEqual(score.completedCount, 3)
        XCTAssertEqual(score.displayPercentage, 100)
    }

    /// §9.4 · Caso 3 — Algunas reprogramadas: se informan aparte, no son fracaso
    func testRescheduledActivitiesAreReportedApartAndDoNotLowerTheScore() {
        let day = TestSupport.date(2026, 8, 6)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .reprogramada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 11), status: .reprogramada),
        ]
        let score = engine.dailyScore(for: day, activities: activities)

        XCTAssertEqual(score.evaluableCount, 1, "Las reprogramadas no entran al denominador.")
        XCTAssertEqual(score.rescheduledCount, 2)
        XCTAssertEqual(score.displayPercentage, 100, "Reprogramar no puede castigar el score.")
    }

    /// §9.4 · Caso 4 — Actividad cancelada: se excluye
    func testCancelledActivitiesAreExcludedFromDenominator() {
        let day = TestSupport.date(2026, 8, 6)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .cancelada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 11), status: .pendiente),
        ]
        let score = engine.dailyScore(for: day, activities: activities)

        XCTAssertEqual(score.evaluableCount, 2)
        XCTAssertEqual(score.cancelledCount, 1)
        XCTAssertEqual(score.displayPercentage, 50)
    }

    /// §9.4 · Caso 5 — Cruce de medianoche
    func testActivityJustAfterMidnightBelongsToTheNewDay() {
        let lateNight = TestSupport.date(2026, 8, 6, 23, 40) // dormir
        let afterMidnight = TestSupport.date(2026, 8, 7, 0, 20) // ya es día 7

        let activities = [
            TestSupport.activity(title: "Dormir", category: .dormir, at: lateNight, status: .completada),
            TestSupport.activity(title: "Nota", category: .nota, at: afterMidnight, status: .pendiente),
        ]

        let day6 = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities)
        let day7 = engine.dailyScore(for: TestSupport.date(2026, 8, 7), activities: activities)

        XCTAssertEqual(day6.evaluableCount, 1)
        XCTAssertEqual(day6.displayPercentage, 100)
        XCTAssertEqual(day7.evaluableCount, 1)
        XCTAssertEqual(day7.displayPercentage, 0)
    }

    /// §9.4 · Caso 6 — Cambio de zona horaria
    func testSameInstantCanBelongToDifferentDaysAcrossTimeZones() {
        let bogota = TestSupport.calendar(timeZoneID: "America/Bogota")
        let madrid = TestSupport.calendar(timeZoneID: "Europe/Madrid")

        // 22:00 en Bogotá = 05:00 del día siguiente en Madrid.
        let instant = TestSupport.date(2026, 8, 6, 22, 0, calendar: bogota)
        let activity = TestSupport.activity(at: instant, status: .completada)

        let bogotaScore = ScoreEngine(calendar: bogota)
            .dailyScore(for: TestSupport.date(2026, 8, 6, 12, 0, calendar: bogota), activities: [activity])
        let madridScore = ScoreEngine(calendar: madrid)
            .dailyScore(for: TestSupport.date(2026, 8, 7, 12, 0, calendar: madrid), activities: [activity])

        XCTAssertEqual(bogotaScore.completedCount, 1, "En Bogotá pertenece al día 6.")
        XCTAssertEqual(madridScore.completedCount, 1, "En Madrid el mismo instante cae en el día 7.")
    }

    /// §9.4 · Caso 7 — Semana parcial: los días sin datos no arrastran la media
    func testPartialWeekIgnoresDaysWithoutData() {
        // Semana del lunes 3 al domingo 9 de agosto de 2026.
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 3, 8), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 4, 8), status: .completada),
        ]
        let weekly = engine.weeklyScore(weekContaining: TestSupport.date(2026, 8, 5), activities: activities)

        XCTAssertEqual(
            weekly.dailyComponent,
            100,
            accuracy: 0.0001,
            "Los cinco días sin datos no deben contar como 0%."
        )
        XCTAssertEqual(weekly.displayScore, 100)
        XCTAssertEqual(weekly.state, .excelente)
    }

    /// §9.4 · Caso 8 — Datos históricos modificados: el score se recalcula, no se conserva
    func testEditingHistoricalDataRecalculatesTheScore() {
        let day = TestSupport.date(2026, 8, 6)
        var activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .pendiente),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .pendiente),
        ]
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities).displayPercentage, 0)

        activities[0].status = .completada
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities).displayPercentage, 50)

        activities[1].status = .cancelada
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities).displayPercentage, 100)
    }

    /// §9.2 — Ponderación 40/20/20/20
    func testWeeklyWeightsSumToOne() {
        let total = WeeklyScore.dailyWeight + WeeklyScore.routineWeight
            + WeeklyScore.keyScheduleWeight + WeeklyScore.commitmentWeight
        XCTAssertEqual(total, 1.0, accuracy: 0.0001)
    }

    func testWeeklyStateThresholdsMatchSpecification() {
        XCTAssertEqual(WeeklyScore.State.forScore(100), .excelente)
        XCTAssertEqual(WeeklyScore.State.forScore(90), .excelente)
        XCTAssertEqual(WeeklyScore.State.forScore(89.9), .muyBien)
        XCTAssertEqual(WeeklyScore.State.forScore(75), .muyBien)
        XCTAssertEqual(WeeklyScore.State.forScore(74.9), .avanzando)
        XCTAssertEqual(WeeklyScore.State.forScore(60), .avanzando)
        XCTAssertEqual(WeeklyScore.State.forScore(59.9), .reorganizar)
        XCTAssertEqual(WeeklyScore.State.forScore(0), .reorganizar)
    }

    func testUnscheduledCategoryDoesNotPenalizeWeeklyScore() {
        // No programar gym en toda la semana no puede bajar el score.
        let activities = [TestSupport.activity(at: TestSupport.date(2026, 8, 3, 8), status: .completada)]
        let weekly = engine.weeklyScore(weekContaining: TestSupport.date(2026, 8, 3), activities: activities)
        XCTAssertEqual(weekly.commitmentComponent, 100, accuracy: 0.0001)
    }

    func testInternalPrecisionIsPreservedWhileDisplayRounds() {
        let day = TestSupport.date(2026, 8, 6)
        let activities = (0 ..< 3).map { index in
            TestSupport.activity(
                at: TestSupport.date(2026, 8, 6, 7 + index),
                status: index == 0 ? .completada : .pendiente
            )
        }
        let score = engine.dailyScore(for: day, activities: activities)

        XCTAssertEqual(score.rawPercentage, 100.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(score.displayPercentage, 33)
    }
}
