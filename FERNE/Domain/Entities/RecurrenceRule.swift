import Foundation

/// Regla de repetición. Se resuelve siempre con `Calendar` + `TimeZone` explícitos
/// para sobrevivir a cambios de zona horaria y horario de verano (MASTER_SPEC §8.2).
public struct RecurrenceRule: Codable, Hashable, Sendable {
    public enum Frequency: String, Codable, CaseIterable, Sendable {
        case diaria
        case semanal
        case mensual
        case personalizada

        public var displayName: String {
            switch self {
            case .diaria: "Cada día"
            case .semanal: "Cada semana"
            case .mensual: "Cada mes"
            case .personalizada: "Días específicos"
            }
        }
    }

    public var frequency: Frequency
    /// Intervalo entre repeticiones (cada N días/semanas/meses). Siempre >= 1.
    public var interval: Int
    /// Días de la semana en formato `Calendar` (1 = domingo … 7 = sábado). Vacío = todos.
    public var weekdays: Set<Int>
    /// Fecha límite opcional.
    public var endDate: Date?

    public init(
        frequency: Frequency,
        interval: Int = 1,
        weekdays: Set<Int> = [],
        endDate: Date? = nil
    ) {
        self.frequency = frequency
        self.interval = max(1, interval)
        self.weekdays = weekdays.filter { (1 ... 7).contains($0) }
        self.endDate = endDate
    }

    public static let daily = RecurrenceRule(frequency: .diaria)
    public static let weekdaysOnly = RecurrenceRule(frequency: .personalizada, weekdays: [2, 3, 4, 5, 6])

    /// ¿Corresponde esta regla a la fecha indicada, partiendo de `anchor`?
    public func occurs(on date: Date, anchor: Date, calendar: Calendar) -> Bool {
        if let endDate, date > endDate {
            return false
        }
        let startDay = calendar.startOfDay(for: anchor)
        let targetDay = calendar.startOfDay(for: date)
        guard targetDay >= startDay else { return false }

        switch frequency {
        case .diaria:
            guard let days = calendar.dateComponents([.day], from: startDay, to: targetDay).day else { return false }
            return days % interval == 0
        case .semanal:
            guard let weeks = calendar.dateComponents([.weekOfYear], from: startDay, to: targetDay).weekOfYear else { return false }
            guard weeks % interval == 0 else { return false }
            if weekdays.isEmpty {
                return calendar.component(.weekday, from: targetDay) == calendar.component(.weekday, from: startDay)
            }
            return weekdays.contains(calendar.component(.weekday, from: targetDay))
        case .mensual:
            guard let months = calendar.dateComponents([.month], from: startDay, to: targetDay).month else { return false }
            guard months % interval == 0 else { return false }
            return calendar.component(.day, from: targetDay) == calendar.component(.day, from: startDay)
        case .personalizada:
            guard !weekdays.isEmpty else { return false }
            return weekdays.contains(calendar.component(.weekday, from: targetDay))
        }
    }

    public var displayName: String {
        switch frequency {
        case .personalizada where !weekdays.isEmpty:
            let names = ["", "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
            return weekdays.sorted().map { names[$0] }.joined(separator: ", ")
        default:
            return interval == 1 ? frequency.displayName : "\(frequency.displayName) (cada \(interval))"
        }
    }
}
