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
        XCTAssertTrue(ActivityStatus.programada.isEvaluable)
        XCTAssertTrue(ActivityStatus.completada.isEvaluable)
        XCTAssertTrue(ActivityStatus.pendiente.isEvaluable)
        XCTAssertTrue(ActivityStatus.omitida.isEvaluable)
        XCTAssertFalse(ActivityStatus.cancelada.isEvaluable)
        XCTAssertFalse(ActivityStatus.reprogramada.isEvaluable)
    }
}
