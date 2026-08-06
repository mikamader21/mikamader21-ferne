import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

final class RecurrenceRuleTests: XCTestCase {
    private let calendar = TestSupport.calendar()

    func testDailyRuleOccursEveryDay() throws {
        let anchor = TestSupport.date(2026, 8, 3, 7, calendar: calendar)
        let rule = RecurrenceRule.daily
        for offset in 0 ..< 10 {
            let day = try XCTUnwrap(calendar.date(byAdding: .day, value: offset, to: anchor))
            XCTAssertTrue(rule.occurs(on: day, anchor: anchor, calendar: calendar))
        }
    }

    func testDailyRuleWithIntervalSkipsDays() throws {
        let anchor = TestSupport.date(2026, 8, 3, 7, calendar: calendar)
        let rule = RecurrenceRule(frequency: .diaria, interval: 3)
        let dayAfter = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: anchor))
        let threeDaysAfter = try XCTUnwrap(calendar.date(byAdding: .day, value: 3, to: anchor))
        XCTAssertTrue(rule.occurs(on: anchor, anchor: anchor, calendar: calendar))
        XCTAssertFalse(rule.occurs(on: dayAfter, anchor: anchor, calendar: calendar))
        XCTAssertTrue(rule.occurs(on: threeDaysAfter, anchor: anchor, calendar: calendar))
    }

    func testWeekdaysOnlyRuleExcludesWeekend() {
        let monday = TestSupport.date(2026, 8, 3, 7, calendar: calendar)
        let saturday = TestSupport.date(2026, 8, 8, 7, calendar: calendar)
        let sunday = TestSupport.date(2026, 8, 9, 7, calendar: calendar)
        let rule = RecurrenceRule.weekdaysOnly

        XCTAssertTrue(rule.occurs(on: monday, anchor: monday, calendar: calendar))
        XCTAssertFalse(rule.occurs(on: saturday, anchor: monday, calendar: calendar))
        XCTAssertFalse(rule.occurs(on: sunday, anchor: monday, calendar: calendar))
    }

    func testRuleStopsAtEndDate() {
        let anchor = TestSupport.date(2026, 8, 3, 7, calendar: calendar)
        let end = TestSupport.date(2026, 8, 5, 23, 59, calendar: calendar)
        let rule = RecurrenceRule(frequency: .diaria, endDate: end)

        XCTAssertTrue(rule.occurs(on: TestSupport.date(2026, 8, 5, 7, calendar: calendar), anchor: anchor, calendar: calendar))
        XCTAssertFalse(rule.occurs(on: TestSupport.date(2026, 8, 6, 7, calendar: calendar), anchor: anchor, calendar: calendar))
    }

    func testRuleNeverOccursBeforeItsAnchor() {
        let anchor = TestSupport.date(2026, 8, 3, 7, calendar: calendar)
        let before = TestSupport.date(2026, 8, 1, 7, calendar: calendar)
        XCTAssertFalse(RecurrenceRule.daily.occurs(on: before, anchor: anchor, calendar: calendar))
    }

    func testIntervalIsClampedToAtLeastOne() {
        XCTAssertEqual(RecurrenceRule(frequency: .diaria, interval: 0).interval, 1)
        XCTAssertEqual(RecurrenceRule(frequency: .diaria, interval: -5).interval, 1)
    }

    func testInvalidWeekdaysAreDiscarded() {
        let rule = RecurrenceRule(frequency: .personalizada, weekdays: [0, 3, 8, 9])
        XCTAssertEqual(rule.weekdays, [3])
    }
}
