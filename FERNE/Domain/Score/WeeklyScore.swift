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

    /// `true` solo si hubo al menos un día con actividades evaluables.
    ///
    /// Sin esto, una semana sin nada devolvería 0 y la UI mostraría "0 %", que es
    /// justo lo que §9.1 prohíbe: un día sin actividades no es un incumplimiento.
    public var hasData: Bool {
        dailyScores.contains(where: \.hasData)
    }

    public var state: State {
        .forScore(rawScore)
    }

    /// Un componente del score semanal, con su valor y su peso.
    public struct Component: Hashable, Codable, Sendable, Identifiable {
        public let label: String
        /// Valor del componente, 0…100.
        public let value: Double
        /// Peso en el total, 0…1.
        public let weight: Double

        public var id: String {
            label
        }

        public init(label: String, value: Double, weight: Double) {
            self.label = label
            self.value = value
            self.weight = weight
        }
    }

    /// Desglose para la pantalla 38 "Detalle del score": el score debe explicarse siempre.
    public var breakdown: [Component] {
        [
            Component(label: "Cumplimiento diario", value: dailyComponent, weight: Self.dailyWeight),
            Component(label: "Rutinas", value: routineComponent, weight: Self.routineWeight),
            Component(label: "Horarios importantes", value: keyScheduleComponent, weight: Self.keyScheduleWeight),
            Component(label: "Compromisos semanales", value: commitmentComponent, weight: Self.commitmentWeight)
        ]
    }

    public static let disclaimer = """
    Tu score no es una calificación personal. Solo sirve para ayudarte a organizar mejor tu semana.
    """
}
