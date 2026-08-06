import Foundation

/// Constancia semanal ponderada (MASTER_SPEC §9.2).
///
/// - Cumplimiento diario: 40%
/// - Rutinas: 20%
/// - Horarios importantes: 20%
/// - Compromisos semanales: 20%
public struct WeeklyScore: Hashable, Codable, Sendable {
    public enum State: String, Codable, Sendable {
        case excelente
        case muyBien
        case avanzando
        case reorganizar

        /// Mensajes aprobados. Nunca usar vocabulario punitivo (§9.3).
        public var message: String {
            switch self {
            case .excelente: "Semana excelente"
            case .muyBien: "Vas muy bien"
            case .avanzando: "Sigues avanzando"
            case .reorganizar: "Vamos a reorganizarlo"
            }
        }

        public static func forScore(_ score: Double) -> State {
            switch score {
            case 90...: .excelente
            case 75 ..< 90: .muyBien
            case 60 ..< 75: .avanzando
            default: .reorganizar
            }
        }
    }

    public static let dailyWeight: Double = 0.40
    public static let routineWeight: Double = 0.20
    public static let keyScheduleWeight: Double = 0.20
    public static let commitmentWeight: Double = 0.20

    public let weekStart: Date
    public let dailyComponent: Double
    public let routineComponent: Double
    public let keyScheduleComponent: Double
    public let commitmentComponent: Double
    public let rawScore: Double
    public let dailyScores: [DailyScore]

    public init(
        weekStart: Date,
        dailyComponent: Double,
        routineComponent: Double,
        keyScheduleComponent: Double,
        commitmentComponent: Double,
        rawScore: Double,
        dailyScores: [DailyScore]
    ) {
        self.weekStart = weekStart
        self.dailyComponent = dailyComponent
        self.routineComponent = routineComponent
        self.keyScheduleComponent = keyScheduleComponent
        self.commitmentComponent = commitmentComponent
        self.rawScore = rawScore
        self.dailyScores = dailyScores
    }

    public var displayScore: Int {
        Int(rawScore.rounded())
    }

    public var state: State {
        .forScore(rawScore)
    }

    /// Desglose para la pantalla 38 "Detalle del score": el score debe explicarse siempre.
    public var breakdown: [(label: String, value: Double, weight: Double)] {
        [
            ("Cumplimiento diario", dailyComponent, Self.dailyWeight),
            ("Rutinas", routineComponent, Self.routineWeight),
            ("Horarios importantes", keyScheduleComponent, Self.keyScheduleWeight),
            ("Compromisos semanales", commitmentComponent, Self.commitmentWeight),
        ]
    }

    public static let disclaimer = """
    Tu score no es una calificación personal. Solo sirve para ayudarte a organizar mejor tu semana.
    """
}
