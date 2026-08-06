import Foundation

/// Conjuntos de datos deterministas para las capturas de QA visual.
///
/// Se separan de `PreviewData` porque las capturas necesitan ser **idénticas
/// entre ejecuciones**: no pueden depender de la hora real ni del día actual,
/// o dos capturas de la misma pantalla nunca serían comparables.
public enum ScreenshotFixtures {
    /// Fecha ancla fija: lunes 3 de agosto de 2026. Todas las capturas la usan.
    public static let anchorDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 3
        components.hour = 9
        components.minute = 0
        return Calendar.ferneDefault.date(from: components) ?? Date(timeIntervalSince1970: 1_785_000_000)
    }()

    private static func at(_ hour: Int, _ minute: Int = 0) -> Date {
        Calendar.ferneDefault.date(
            bySettingHour: hour, minute: minute, second: 0, of: anchorDate
        ) ?? anchorDate
    }

    /// Día típico: mezcla de completadas y pendientes.
    public static var mixto: [ActivitySnapshot] {
        [
            ActivitySnapshot(
                title: "Despertar",
                category: .despertar,
                startDate: at(6, 30),
                priority: .esencial,
                status: .completada,
                completedAt: at(6, 32)
            ),
            ActivitySnapshot(
                title: "Desayuno",
                category: .comida,
                startDate: at(8, 0),
                status: .completada,
                completedAt: at(8, 15)
            ),
            ActivitySnapshot(
                title: "Gym",
                category: .gym,
                startDate: at(10, 0),
                endDate: at(11, 0),
                status: .completada,
                completedAt: at(11, 5)
            ),
            ActivitySnapshot(title: "Almuerzo", category: .comida, startDate: at(13, 0), status: .pendiente),
            ActivitySnapshot(
                title: "TikTok Live",
                category: .live,
                startDate: at(19, 0),
                endDate: at(20, 0),
                priority: .importante,
                status: .programada
            ),
            ActivitySnapshot(title: "Lectura", category: .lectura, startDate: at(21, 0), status: .programada),
            ActivitySnapshot(
                title: "Dormir",
                category: .dormir,
                startDate: at(23, 45),
                priority: .esencial,
                status: .programada
            )
        ]
    }

    /// Todo completado: alimenta la escena de "Día completado" y el 100%.
    public static var completo: [ActivitySnapshot] {
        mixto.map { activity in
            var copy = activity
            copy.status = .completada
            copy.completedAt = activity.startDate
            return copy
        }
    }

    /// Sin actividades: estado vacío.
    public static var vacio: [ActivitySnapshot] {
        []
    }

    public static func activities(for fixture: UITestConfiguration.Fixture) -> [ActivitySnapshot] {
        switch fixture {
        case .mixto: mixto
        case .completo: completo
        case .vacio: vacio
        }
    }
}
