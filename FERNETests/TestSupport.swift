import Foundation
import XCTest

#if canImport(FERNE)
    @testable import FERNE
#else
    @testable import FerneDomain
#endif

/// Utilidades compartidas por las pruebas de dominio.
/// No dependen de SwiftUI ni de SwiftData, por lo que corren también con `Scripts/verify-logic.sh`.
enum TestSupport {
    /// Calendario determinista anclado a Bogotá (zona de referencia de la usuaria).
    static func calendar(timeZoneID: String = "America/Bogota") -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "es_ES")
        calendar.timeZone = TimeZone(identifier: timeZoneID) ?? .gmt
        return calendar
    }

    static func date(
        _ year: Int, _ month: Int, _ day: Int,
        _ hour: Int = 0, _ minute: Int = 0,
        calendar: Calendar = TestSupport.calendar()
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        guard let date = calendar.date(from: components) else {
            fatalError("Fecha de prueba inválida: \(year)-\(month)-\(day) \(hour):\(minute)")
        }
        return date
    }

    static func activity(
        title: String = "Actividad",
        category: ActivityCategory = .evento,
        at date: Date,
        status: ActivityStatus = .programada,
        priority: Priority = .normal
    ) -> ActivitySnapshot {
        ActivitySnapshot(
            title: title,
            category: category,
            startDate: date,
            priority: priority,
            status: status,
            completedAt: status == .completada ? date : nil,
            createdAt: date,
            updatedAt: date
        )
    }
}
