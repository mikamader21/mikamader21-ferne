import Foundation

/// Resultado del score de un día (MASTER_SPEC §9.1).
///
/// `score diario = completadas / actividades evaluables × 100`
public struct DailyScore: Hashable, Codable, Sendable {
    public let day: Date
    public let evaluableCount: Int
    public let completedCount: Int
    public let pendingCount: Int
    public let rescheduledCount: Int
    public let cancelledCount: Int
    /// Precisión completa 0…100. La UI redondea; el dominio conserva el valor exacto.
    public let rawPercentage: Double

    public init(
        day: Date,
        evaluableCount: Int,
        completedCount: Int,
        pendingCount: Int,
        rescheduledCount: Int,
        cancelledCount: Int,
        rawPercentage: Double
    ) {
        self.day = day
        self.evaluableCount = evaluableCount
        self.completedCount = completedCount
        self.pendingCount = pendingCount
        self.rescheduledCount = rescheduledCount
        self.cancelledCount = cancelledCount
        self.rawPercentage = rawPercentage
    }

    /// Valor mostrado al usuario.
    public var displayPercentage: Int { Int(rawPercentage.rounded()) }

    /// Un día sin actividades evaluables no es un 0%: es un día sin datos.
    public var hasData: Bool { evaluableCount > 0 }
}
