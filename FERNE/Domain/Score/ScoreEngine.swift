import Foundation

/// Motor de score de FERNÉ (MASTER_SPEC §9).
///
/// Tipo **puro**: sin estado, sin SwiftData, sin SwiftUI, sin `Date()` implícito.
/// El calendario y el "ahora" se inyectan, lo que permite probar cambios de zona
/// horaria, horario de verano y cruces de medianoche (§9.4).
///
/// Principio que gobierna todo el cálculo: **solo puntúa lo que ya venció y tiene
/// respuesta**. Lo que aún puede hacerse no resta.
public struct ScoreEngine: Sendable {
    public let calendar: Calendar

    public init(calendar: Calendar = .ferneDefault) {
        self.calendar = calendar
    }

    // MARK: - Score diario

    /// Score de un día, provisional mientras el día no termina.
    ///
    /// - Completada 1.0 · Parcial 0.5 · Omitida 0.0
    /// - Excluidas del denominador: futuras, en curso, reprogramadas, canceladas y
    ///   las que vencieron sin confirmar.
    public func dailyScore(for day: Date, activities: [ActivitySnapshot], now: Date) -> DailyScore {
        let targetDay = calendar.startOfDay(for: day)
        let sameDay = activities.filter { $0.day(in: calendar) == targetDay }
        var tally = Tally()

        for activity in sameDay {
            tally.add(classify(activity, now: now), status: activity.status)
        }

        return tally.result(day: targetDay)
    }

    /// En qué cubo cae una actividad. Separar la clasificación del recuento mantiene
    /// ambas piezas simples y hace explícita cada regla del score.
    private enum Bucket {
        case cancelled
        case rescheduled
        case running
        /// Su ventana no ha cerrado: todavía puede hacerse.
        case upcoming
        /// Cerró sin respuesta. No es un fallo.
        case unconfirmed
        /// Cerró con respuesta, y estos son sus puntos (0, 0.5 o 1).
        case scored(Double)
    }

    private func classify(_ activity: ActivitySnapshot, now: Date) -> Bucket {
        switch activity.status {
        case .cancelada: return .cancelled
        case .reprogramada: return .rescheduled
        case .enCurso: return .running
        default: break
        }
        if let fraction = activity.contribution(at: now, calendar: calendar) {
            return .scored(fraction)
        }
        return activity.hasClosed(at: now, calendar: calendar) ? .unconfirmed : .upcoming
    }

    /// Acumulador de los recuentos del día.
    private struct Tally {
        var earned = 0.0
        var possible = 0.0
        var completed = 0, partial = 0, missed = 0
        var unconfirmed = 0, upcoming = 0, running = 0
        var rescheduled = 0, cancelled = 0

        mutating func add(_ bucket: Bucket, status: ActivityStatus) {
            switch bucket {
            case .cancelled: cancelled += 1
            case .rescheduled: rescheduled += 1
            case .running: running += 1
            case .upcoming: upcoming += 1
            case .unconfirmed: unconfirmed += 1
            case let .scored(fraction):
                earned += fraction
                possible += 1
                switch status {
                case .completada: completed += 1
                case .parcial: partial += 1
                default: missed += 1
                }
            }
        }

        func result(day: Date) -> DailyScore {
            DailyScore(
                day: day,
                evaluableCount: Int(possible),
                completedCount: completed,
                partialCount: partial,
                missedCount: missed,
                unconfirmedCount: unconfirmed,
                upcomingCount: upcoming,
                inProgressCount: running,
                rescheduledCount: rescheduled,
                cancelledCount: cancelled,
                rawPercentage: possible > 0 ? earned / possible * 100 : 0
            )
        }
    }

    // MARK: - Constancia semanal

    /// Constancia semanal ponderada 40/20/20/20 (§9.2).
    ///
    /// Los días **sin resultados** se ignoran: incluir el jueves cuando es martes
    /// daría un score falso y desalentador.
    public func weeklyScore(
        weekContaining date: Date,
        activities: [ActivitySnapshot],
        now: Date,
        routineCompletion: Double? = nil
    ) -> WeeklyScore {
        let start = startOfWeek(for: date)
        let days = (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        let daily = days.map { dailyScore(for: $0, activities: activities, now: now) }

        let daysWithData = daily.filter(\.hasData)
        let dailyComponent = daysWithData.isEmpty
            ? 0
            : daysWithData.map(\.rawPercentage).reduce(0, +) / Double(daysWithData.count)

        let weekActivities = activities.filter { activity in
            let day = activity.day(in: calendar)
            return day >= start && day < (calendar.date(byAdding: .day, value: 7, to: start) ?? start)
        }

        let routineComponent = routineCompletion
            ?? completionRate(of: weekActivities.filter { $0.category == .rutina }, now: now)
        let keyScheduleComponent = completionRate(of: weekActivities.filter(\.category.isKeySchedule), now: now)
        let commitmentComponent = completionRate(of: weekActivities.filter(\.category.isWeeklyCommitment), now: now)

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

    /// Sin resultados de ese tipo en la semana ⇒ el componente no penaliza (100).
    /// No haber programado gym no es un incumplimiento.
    private func completionRate(of activities: [ActivitySnapshot], now: Date) -> Double {
        let closed = activities.compactMap { $0.contribution(at: now, calendar: calendar) }
        guard !closed.isEmpty else { return 100 }
        return closed.reduce(0, +) / Double(closed.count) * 100
    }

    public func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) }
            ?? calendar.startOfDay(for: date)
    }
}

public extension Calendar {
    /// Calendario canónico de FERNÉ: semana de lunes a domingo, locale es-ES.
    /// Usar siempre este en el dominio, nunca `Calendar.current` implícito.
    static var ferneDefault: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // lunes
        calendar.locale = Locale(identifier: "es_ES")
        return calendar
    }
}
