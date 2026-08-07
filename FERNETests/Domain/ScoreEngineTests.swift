import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

/// Cubre los ocho casos obligatorios de MASTER_SPEC §9.4 más las reglas de score
/// provisional: solo puntúa lo que ya venció y tiene respuesta.
final class ScoreEngineTests: XCTestCase {
    private let calendar = TestSupport.calendar()
    private var engine: ScoreEngine {
        ScoreEngine(calendar: calendar)
    }

    /// Un instante después de todas las actividades del día de prueba.
    private var endOfDay: Date {
        TestSupport.date(2026, 8, 6, 23, 59)
    }

    // MARK: - §9.4 · casos obligatorios

    func testDayWithoutActivitiesHasNoDataAndDoesNotScoreZeroAsFailure() {
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: [], now: endOfDay)
        XCTAssertEqual(score.evaluableCount, 0)
        XCTAssertFalse(score.hasData, "Un día sin actividades no tiene datos; no es un 0 % de cumplimiento.")
        XCTAssertEqual(score.rawPercentage, 0, accuracy: 0.0001)
    }

    func testAllCompletedGivesOneHundred() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 13), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 20), status: .completada)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)
        XCTAssertEqual(score.evaluableCount, 3)
        XCTAssertEqual(score.completedCount, 3)
        XCTAssertEqual(score.displayPercentage, 100)
    }

    func testRescheduledActivitiesAreReportedApartAndDoNotLowerTheScore() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .reprogramada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 11), status: .reprogramada)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)
        XCTAssertEqual(score.evaluableCount, 1, "Las reprogramadas no entran al denominador.")
        XCTAssertEqual(score.rescheduledCount, 2)
        XCTAssertEqual(score.displayPercentage, 100, "Reprogramar no puede castigar el score.")
    }

    func testCancelledActivitiesAreExcludedFromDenominator() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .cancelada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 11), status: .omitida)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)
        XCTAssertEqual(score.evaluableCount, 2)
        XCTAssertEqual(score.cancelledCount, 1)
        XCTAssertEqual(score.displayPercentage, 50)
    }

    func testActivityJustAfterMidnightBelongsToTheNewDay() {
        let lateNight = TestSupport.date(2026, 8, 6, 23, 40)
        let afterMidnight = TestSupport.date(2026, 8, 7, 0, 20)
        let activities = [
            TestSupport.activity(title: "Dormir", category: .dormir, at: lateNight, status: .completada),
            TestSupport.activity(title: "Nota", category: .nota, at: afterMidnight, status: .omitida)
        ]
        let reference = TestSupport.date(2026, 8, 7, 12)
        let day6 = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: reference)
        let day7 = engine.dailyScore(for: TestSupport.date(2026, 8, 7), activities: activities, now: reference)

        XCTAssertEqual(day6.evaluableCount, 1)
        XCTAssertEqual(day6.displayPercentage, 100)
        XCTAssertEqual(day7.evaluableCount, 1)
        XCTAssertEqual(day7.displayPercentage, 0)
    }

    func testSameInstantCanBelongToDifferentDaysAcrossTimeZones() {
        let bogota = TestSupport.calendar(timeZoneID: "America/Bogota")
        let madrid = TestSupport.calendar(timeZoneID: "Europe/Madrid")
        let instant = TestSupport.date(2026, 8, 6, 22, 0, calendar: bogota)
        let activity = TestSupport.activity(at: instant, status: .completada)
        let later = TestSupport.date(2026, 8, 8, 12, 0, calendar: bogota)

        let bogotaScore = ScoreEngine(calendar: bogota)
            .dailyScore(for: TestSupport.date(2026, 8, 6, 12, 0, calendar: bogota), activities: [activity], now: later)
        let madridScore = ScoreEngine(calendar: madrid)
            .dailyScore(for: TestSupport.date(2026, 8, 7, 12, 0, calendar: madrid), activities: [activity], now: later)

        XCTAssertEqual(bogotaScore.completedCount, 1, "En Bogotá pertenece al día 6.")
        XCTAssertEqual(madridScore.completedCount, 1, "En Madrid el mismo instante cae en el día 7.")
    }

    func testPartialWeekIgnoresDaysWithoutData() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 3, 8), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 4, 8), status: .completada)
        ]
        let weekly = engine.weeklyScore(
            weekContaining: TestSupport.date(2026, 8, 5),
            activities: activities,
            now: TestSupport.date(2026, 8, 5, 12)
        )
        XCTAssertEqual(
            weekly.dailyComponent,
            100,
            accuracy: 0.0001,
            "Los cinco días sin datos no deben contar como 0 %."
        )
        XCTAssertEqual(weekly.displayScore, 100)
        XCTAssertEqual(weekly.state, .excelente)
    }

    func testEditingHistoricalDataRecalculatesTheScore() {
        let day = TestSupport.date(2026, 8, 6)
        var activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .omitida),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .omitida)
        ]
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities, now: endOfDay).displayPercentage, 0)

        activities[0].status = .completada
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities, now: endOfDay).displayPercentage, 50)

        activities[1].status = .cancelada
        XCTAssertEqual(engine.dailyScore(for: day, activities: activities, now: endOfDay).displayPercentage, 100)
    }

    // MARK: - Score provisional

    func testFutureActivitiesAreExcludedInsteadOfCountingAsZero() {
        let now = TestSupport.date(2026, 8, 6, 9)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 19), status: .programada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 21), status: .proxima)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: now)

        XCTAssertEqual(score.evaluableCount, 1, "Solo cuenta la que ya venció.")
        XCTAssertEqual(score.upcomingCount, 2)
        XCTAssertEqual(score.displayPercentage, 100, "Las futuras no pueden bajar el score.")
    }

    func testInProgressIsExcludedBecauseStartingIsNotFinishing() {
        let now = TestSupport.date(2026, 8, 6, 10, 30)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(title: "Gym", category: .gym, at: TestSupport.date(2026, 8, 6, 10), status: .enCurso)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: now)

        XCTAssertEqual(score.inProgressCount, 1)
        XCTAssertEqual(score.evaluableCount, 1, "Empezar no suma ni resta.")
        XCTAssertEqual(score.displayPercentage, 100)
    }

    func testPartialCountsAsHalf() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .parcial)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)

        XCTAssertEqual(score.partialCount, 1)
        XCTAssertEqual(score.rawPercentage, 75, accuracy: 0.0001, "1.0 + 0.5 sobre 2 = 75 %.")
    }

    func testMissedCountsAsZeroButOnlyWhenConfirmed() {
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .omitida)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)
        XCTAssertEqual(score.missedCount, 1)
        XCTAssertEqual(score.displayPercentage, 50)
    }

    func testUnconfirmedIsSeparatedFromFailure() {
        // Venció a las 07:15 y nadie confirmó nada. No es un fallo: falta la respuesta.
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .sinConfirmar),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 8), status: .completada)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)

        XCTAssertEqual(score.unconfirmedCount, 1)
        XCTAssertEqual(score.evaluableCount, 1, "Sin confirmar no entra al denominador.")
        XCTAssertEqual(score.missedCount, 0, "Sin confirmar no es lo mismo que no hecho.")
        XCTAssertEqual(score.displayPercentage, 100)
    }

    func testWindowUsesCategoryDurationWhenNoEndDateIsGiven() {
        // Gym sugiere 60 min: a las 10:30 sigue abierta; a las 11:30 ya cerró.
        let gym = TestSupport.activity(
            title: "Gym", category: .gym,
            at: TestSupport.date(2026, 8, 6, 10), status: .omitida
        )
        let during = engine.dailyScore(
            for: TestSupport.date(2026, 8, 6), activities: [gym],
            now: TestSupport.date(2026, 8, 6, 10, 30)
        )
        let after = engine.dailyScore(
            for: TestSupport.date(2026, 8, 6), activities: [gym],
            now: TestSupport.date(2026, 8, 6, 11, 30)
        )

        XCTAssertEqual(during.evaluableCount, 0, "Su ventana no ha cerrado.")
        XCTAssertEqual(after.evaluableCount, 1)
    }

    func testWeeklyScoreDoesNotCountFutureDaysAsZero() {
        // Es martes. Miércoles a domingo tienen actividades programadas, aún futuras.
        let now = TestSupport.date(2026, 8, 4, 12)
        var activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 3, 8), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 4, 8), status: .completada)
        ]
        for dayOffset in 5 ... 9 {
            activities.append(
                TestSupport.activity(at: TestSupport.date(2026, 8, dayOffset, 8), status: .programada)
            )
        }
        let weekly = engine.weeklyScore(
            weekContaining: now, activities: activities, now: now
        )
        XCTAssertEqual(weekly.dailyComponent, 100, accuracy: 0.0001)
        XCTAssertEqual(weekly.displayScore, 100, "Los días futuros no pueden contar como cero.")
    }

    // MARK: - §9.2 · ponderación

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
        let activities = [TestSupport.activity(at: TestSupport.date(2026, 8, 3, 8), status: .completada)]
        let weekly = engine.weeklyScore(
            weekContaining: TestSupport.date(2026, 8, 3),
            activities: activities,
            now: TestSupport.date(2026, 8, 9, 23)
        )
        XCTAssertEqual(weekly.commitmentComponent, 100, accuracy: 0.0001)
    }

    func testInternalPrecisionIsPreservedWhileDisplayRounds() {
        let activities = (0 ..< 3).map { index in
            TestSupport.activity(
                at: TestSupport.date(2026, 8, 6, 7 + index),
                status: index == 0 ? .completada : .omitida
            )
        }
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: endOfDay)

        XCTAssertEqual(score.rawPercentage, 100.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(score.displayPercentage, 33)
    }

    func testSummariesDescribeTheDayWithoutJudging() {
        let now = TestSupport.date(2026, 8, 6, 14)
        let activities = [
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 7), status: .completada),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 9), status: .parcial),
            TestSupport.activity(at: TestSupport.date(2026, 8, 6, 20), status: .programada)
        ]
        let score = engine.dailyScore(for: TestSupport.date(2026, 8, 6), activities: activities, now: now)

        XCTAssertEqual(score.confirmedSummary, "2 de 3 compromisos confirmados")
        XCTAssertEqual(score.remainingSummary, "Queda 1 por completar")
        XCTAssertFalse(ScoreLanguage.containsForbiddenTerm(score.confirmedSummary))
    }
}
