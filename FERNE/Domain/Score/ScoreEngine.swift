import Foundation

/// Motor de score de FERNÉ (MASTER_SPEC §9).
///
/// Es un tipo **puro**: sin estado, sin SwiftData, sin SwiftUI, sin `Date()` implícito.
/// Todo depende del `Calendar` que se le inyecta, lo que permite probar cambios de
/// zona horaria, horario de verano y cruces de medianoche (§9.4).
public struct ScoreEngine: Sendable {
    public let calendar: Calendar

    public init(calendar: Calendar = .ferneDefault) {
        self.calendar = calendar
    }

    // MARK: - Score diario

    /// `score diario = completadas / actividades evaluables × 100`
    ///
    /// - Las **canceladas** se excluyen del denominador.
    /// - Las **reprogramadas** se informan aparte y no cuentan como fracaso
    ///   (tampoco entran al denominador del día original).
    /// - Un día sin actividades evaluables devuelve `rawPercentage == 0` con `hasData == false`.
    public func dailyScore(for day: Date, activities: [ActivitySnapshot]) -> DailyScore {
        let targetDay = calendar.startOfDay(for: day)
        let sameDay = activities.filter { $0.day(in: calendar) == targetDay }

        let evaluable = sameDay.filter(\.isEvaluable)
        let completed = evaluable.filter(\.isCompleted)
        let pending = evaluable.filter { !$0.isCompleted }
        let rescheduled = sameDay.filter { $0.status == .reprogramada }
        let cancelled = sameDay.filter { $0.status == .cancelada }

        let percentage: Double = evaluable.isEmpty
            ? 0
            : Double(completed.count) / Double(evaluable.count) * 100

        return DailyScore(
            day: targetDay,
            evaluableCount: evaluable.count,
            completedCount: completed.count,
            pendingCount: pending.count,
            rescheduledCount: rescheduled.count,
            cancelledCount: cancelled.count,
            rawPercentage: percentage
        )
    }

    // MARK: - Constancia semanal

    /// Constancia semanal ponderada 40/20/20/20 (§9.2).
    ///
    /// Los días sin datos **no** arrastran la media hacia abajo: se ignoran.
    /// Una semana parcial se evalúa solo sobre los días con datos.
    public func weeklyScore(
        weekContaining date: Date,
        activities: [ActivitySnapshot],
        routineCompletion: Double? = nil
    ) -> WeeklyScore {
        let start = startOfWeek(for: date)
        let days = (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        let daily = days.map { dailyScore(for: $0, activities: activities) }

        let daysWithData = daily.filter(\.hasData)
        let dailyComponent = daysWithData.isEmpty
            ? 0
            : daysWithData.map(\.rawPercentage).reduce(0, +) / Double(daysWithData.count)

        let weekActivities = activities.filter { activity in
            let day = activity.day(in: calendar)
            return day >= start && day < (calendar.date(byAdding: .day, value: 7, to: start) ?? start)
        }

        let routineComponent = routineCompletion
            ?? completionRate(of: weekActivities.filter { $0.category == .rutina })
        let keyScheduleComponent = completionRate(of: weekActivities.filter(\.category.isKeySchedule))
        let commitmentComponent = completionRate(of: weekActivities.filter(\.category.isWeeklyCommitment))

        let raw = dailyComponent * WeeklyScore.dailyWeight
            + routineComponent * WeeklyScore.routineWeight
            + keyScheduleComponent * WeeklyScore.keyScheduleWeight
            + commitmentComponent * WeeklyScore.commitmentWeight

        return WeeklyScore(
            weekStart: start,
            dailyComponent: dailyComponent,
            routineComponent: routineComponent,
            keyScheduleComponent: keyScheduleComponent,
            commitmentComponent: commitmentComponent,
            rawScore: raw,
            dailyScores: daily
        )
    }

    // MARK: - Helpers

    /// Sin actividades de ese tipo en la semana ⇒ el componente no penaliza (100).
    /// No haber programado gym no es un incumplimiento.
    private func completionRate(of activities: [ActivitySnapshot]) -> Double {
        let evaluable = activities.filter(\.isEvaluable)
        guard !evaluable.isEmpty else { return 100 }
        let completed = evaluable.filter(\.isCompleted).count
        return Double(completed) / Double(evaluable.count) * 100
    }

    public func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) }
            ?? calendar.startOfDay(for: date)
    }
}

public extension Calendar {
    /// Calendario canónico de FERNÉ: semana de lunes a domingo, locale es-ES.
    /// Usar siempre este, nunca `Calendar.current` de forma implícita en el dominio.
    static var ferneDefault: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // lunes
        calendar.locale = Locale(identifier: "es_ES")
        return calendar
    }
}
