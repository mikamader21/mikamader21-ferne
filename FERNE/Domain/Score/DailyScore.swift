import Foundation

/// Resultado del score de un día (MASTER_SPEC §9.1, ampliado).
///
/// El score es **provisional durante el día**: solo cuentan las actividades cuya
/// ventana ya cerró. Lo que aún puede hacerse no resta.
public struct DailyScore: Hashable, Codable, Sendable {
    public let day: Date
    /// Actividades cerradas y con resultado confirmado. Es el denominador.
    public let evaluableCount: Int
    public let completedCount: Int
    public let partialCount: Int
    public let missedCount: Int
    /// Cerradas pero sin respuesta de Fer. **No** cuentan como fallo.
    public let unconfirmedCount: Int
    /// Aún no les toca.
    public let upcomingCount: Int
    public let inProgressCount: Int
    public let rescheduledCount: Int
    public let cancelledCount: Int
    /// Precisión completa 0…100. La UI redondea; el dominio conserva el valor exacto.
    public let rawPercentage: Double

    public init(
        day: Date,
        evaluableCount: Int,
        completedCount: Int,
        partialCount: Int,
        missedCount: Int,
        unconfirmedCount: Int,
        upcomingCount: Int,
        inProgressCount: Int,
        rescheduledCount: Int,
        cancelledCount: Int,
        rawPercentage: Double
    ) {
        self.day = day
        self.evaluableCount = evaluableCount
        self.completedCount = completedCount
        self.partialCount = partialCount
        self.missedCount = missedCount
        self.unconfirmedCount = unconfirmedCount
        self.upcomingCount = upcomingCount
        self.inProgressCount = inProgressCount
        self.rescheduledCount = rescheduledCount
        self.cancelledCount = cancelledCount
        self.rawPercentage = rawPercentage
    }

    /// Valor mostrado al usuario.
    public var displayPercentage: Int {
        Int(rawPercentage.rounded())
    }

    /// Un día sin resultados confirmados no es un 0 %: es un día sin datos.
    public var hasData: Bool {
        evaluableCount > 0
    }

    /// Compromisos del día que todavía esperan algo de Fer.
    public var openCount: Int {
        upcomingCount + inProgressCount + unconfirmedCount
    }

    /// Total de compromisos del día, sin contar cancelados.
    public var commitmentCount: Int {
        evaluableCount + openCount + rescheduledCount
    }

    /// "5 de 7 compromisos confirmados".
    public var confirmedSummary: String {
        "\(evaluableCount) de \(commitmentCount) compromisos confirmados"
    }

    /// "Quedan 2 por completar". `nil` si no queda nada abierto.
    public var remainingSummary: String? {
        guard openCount > 0 else { return nil }
        return openCount == 1 ? "Queda 1 por completar" : "Quedan \(openCount) por completar"
    }

    public static func empty(day: Date) -> DailyScore {
        DailyScore(
            day: day, evaluableCount: 0, completedCount: 0, partialCount: 0,
            missedCount: 0, unconfirmedCount: 0, upcomingCount: 0, inProgressCount: 0,
            rescheduledCount: 0, cancelledCount: 0, rawPercentage: 0
        )
    }
}
