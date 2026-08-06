import Foundation
import XCTest

#if canImport(FERNE)
@testable import FERNE
#else
@testable import FerneDomain
#endif

/// El lenguaje amable de §9.3 se verifica con pruebas, no solo con documentación.
final class ScoreLanguageTests: XCTestCase {
    func testForbiddenVocabularyIsDetected() {
        XCTAssertTrue(ScoreLanguage.containsForbiddenTerm("Fue un fracaso esta semana"))
        XCTAssertTrue(ScoreLanguage.containsForbiddenTerm("Constancia INSUFICIENTE"))
        XCTAssertTrue(ScoreLanguage.containsForbiddenTerm("estuviste perezosa"))
    }

    func testDetectionIgnoresAccentsAndCase() {
        XCTAssertTrue(ScoreLanguage.containsForbiddenTerm("PENALIZACION aplicada"))
        XCTAssertTrue(ScoreLanguage.containsForbiddenTerm("un poco de verguenza"))
    }

    func testApprovedCopyPassesTheGuard() {
        XCTAssertFalse(ScoreLanguage.containsForbiddenTerm("Vamos a reorganizarlo"))
        XCTAssertFalse(ScoreLanguage.containsForbiddenTerm("Sigues avanzando"))
        XCTAssertFalse(ScoreLanguage.containsForbiddenTerm("Lo hiciste, Fer ✨"))
    }

    func testEveryWeeklyStateMessageUsesApprovedLanguage() {
        for state in [WeeklyScore.State.excelente, .muyBien, .avanzando, .reorganizar] {
            XCTAssertFalse(
                ScoreLanguage.containsForbiddenTerm(state.message),
                "El mensaje '\(state.message)' contiene vocabulario prohibido."
            )
        }
    }

    func testEveryStatusDisplayNameUsesApprovedLanguage() {
        for status in ActivityStatus.allCases {
            XCTAssertFalse(
                ScoreLanguage.containsForbiddenTerm(status.displayName),
                "El estado '\(status.displayName)' contiene vocabulario prohibido."
            )
        }
    }

    func testScoreDisclaimerIsPresentAndKind() {
        XCTAssertTrue(WeeklyScore.disclaimer.contains("no es una calificación personal"))
        XCTAssertFalse(ScoreLanguage.containsForbiddenTerm(WeeklyScore.disclaimer))
    }

    func testRecommendationFollowsTheFourPartFormat() {
        let recommendation = Recommendation.example
        XCTAssertFalse(recommendation.observation.isEmpty)
        XCTAssertFalse(recommendation.explanation.isEmpty)
        XCTAssertFalse(recommendation.suggestedChange.isEmpty)
        XCTAssertNotNil(recommendation.actionLabel)
        XCTAssertTrue(recommendation.usesApprovedLanguage)
    }
}
