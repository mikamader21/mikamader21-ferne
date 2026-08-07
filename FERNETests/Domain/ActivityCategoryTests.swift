import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

final class ActivityCategoryTests: XCTestCase {
    /// Los `rawValue` son persistentes: cambiarlos rompe los datos ya guardados.
    func testRawValuesAreStable() {
        let expected: Set<String> = [
            "despertar", "comida", "gym", "trabajo", "live", "lectura",
            "pago", "rutina", "evento", "nota", "dormir", "personal"
        ]
        XCTAssertEqual(Set(ActivityCategory.allCases.map(\.rawValue)), expected)
    }

    func testSpecificationDefinesTwelveCategories() {
        XCTAssertEqual(ActivityCategory.allCases.count, 12)
    }

    func testEveryCategoryHasDisplayNameAndSymbol() {
        for category in ActivityCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty)
            XCTAssertFalse(category.symbolName.isEmpty)
        }
    }

    func testKeyScheduleCategoriesMatchSpecification() {
        let keys = ActivityCategory.allCases.filter(\.isKeySchedule)
        XCTAssertEqual(Set(keys), [.despertar, .comida, .dormir])
    }

    func testWeeklyCommitmentCategoriesMatchSpecification() {
        let commitments = ActivityCategory.allCases.filter(\.isWeeklyCommitment)
        XCTAssertEqual(Set(commitments), [.gym, .live, .lectura])
    }

    func testOnlyEssentialPriorityRequestsProminentAlarm() {
        XCTAssertTrue(Priority.esencial.deservesProminentAlarm)
        XCTAssertFalse(Priority.importante.deservesProminentAlarm)
        XCTAssertFalse(Priority.normal.deservesProminentAlarm)
        XCTAssertFalse(Priority.suave.deservesProminentAlarm)
    }

    func testStatusEvaluabilityMatchesScoreRules() {
        XCTAssertTrue(ActivityStatus.completada.isEvaluable)
        XCTAssertTrue(ActivityStatus.parcial.isEvaluable)
        XCTAssertTrue(ActivityStatus.omitida.isEvaluable)

        XCTAssertFalse(ActivityStatus.programada.isEvaluable)
        XCTAssertFalse(ActivityStatus.proxima.isEvaluable)
        XCTAssertFalse(ActivityStatus.enCurso.isEvaluable, "Empezar no es cumplir.")
        XCTAssertFalse(ActivityStatus.sinConfirmar.isEvaluable, "Falta la respuesta, no es un fallo.")
        XCTAssertFalse(ActivityStatus.reprogramada.isEvaluable)
        XCTAssertFalse(ActivityStatus.cancelada.isEvaluable)
    }

    func testEarnedFractionMatchesTheAgreedPoints() {
        XCTAssertEqual(ActivityStatus.completada.earnedFraction, 1.0)
        XCTAssertEqual(ActivityStatus.parcial.earnedFraction, 0.5)
        XCTAssertEqual(ActivityStatus.omitida.earnedFraction, 0.0)
        XCTAssertNil(ActivityStatus.enCurso.earnedFraction)
        XCTAssertNil(ActivityStatus.sinConfirmar.earnedFraction)
    }

    func testLegacyPendienteMapsToUnconfirmed() {
        // `pendiente` era el nombre anterior. Los datos ya guardados deben seguir leyéndose.
        XCTAssertEqual(ActivityStatus.fromStored("pendiente"), .sinConfirmar)
        XCTAssertEqual(ActivityStatus.fromStored("completada"), .completada)
        XCTAssertEqual(ActivityStatus.fromStored("valor-inexistente"), .programada)
    }

    func testEveryCategoryHasSuggestedDurationAndVerb() {
        for category in ActivityCategory.allCases {
            XCTAssertGreaterThan(category.suggestedDurationMinutes, 0)
            XCTAssertFalse(category.completionVerb.isEmpty)
            XCTAssertFalse(
                ScoreLanguage.containsForbiddenTerm(category.completionVerb),
                "El verbo '\(category.completionVerb)' usa vocabulario prohibido."
            )
        }
    }

    func testCompletionVerbsAreSpecificPerCategory() {
        XCTAssertEqual(ActivityCategory.despertar.completionVerb, "Ya me levanté")
        XCTAssertEqual(ActivityCategory.comida.completionVerb, "Ya comí")
        XCTAssertEqual(ActivityCategory.gym.completionVerb, "Entrenamiento cumplido")
        XCTAssertEqual(ActivityCategory.lectura.completionVerb, "Terminé mi lectura")
        XCTAssertEqual(ActivityCategory.live.completionVerb, "Hice el live")
        XCTAssertEqual(ActivityCategory.pago.completionVerb, "Recibo pagado")
        XCTAssertEqual(ActivityCategory.dormir.completionVerb, "Ya estoy en la cama")
        XCTAssertEqual(ActivityCategory.trabajo.completionVerb, "Tarea terminada")
        XCTAssertEqual(ActivityCategory.personal.completionVerb, "Actividad cumplida")
    }
}
