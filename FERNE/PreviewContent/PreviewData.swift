import Foundation

/// Datos de preview y de QA visual.
///
/// Deterministas a propósito: las capturas de la Fase 8 deben ser reproducibles.
/// **No** se usan en producción; viven en `PreviewContent`, excluido del build de release.
public enum PreviewData {
    public static let calendar: Calendar = .ferneDefault

    private static var todayStart: Date {
        calendar.startOfDay(for: Date())
    }

    private static func at(_ hour: Int, _ minute: Int = 0, dayOffset: Int = 0) -> Date {
        let base = calendar.date(byAdding: .day, value: dayOffset, to: todayStart) ?? todayStart
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    public static let dailyMessage = "Hoy no tienes que hacerlo todo. Solo lo que importa, a tu ritmo."

    /// Actividades del día.
    ///
    /// Bajo UI tests devuelve el fixture determinista solicitado por el argumento
    /// de lanzamiento, para que dos capturas de la misma pantalla sean idénticas.
    public static var today: [ActivitySnapshot] {
        if UITestConfiguration.isActive {
            return ScreenshotFixtures.activities(for: UITestConfiguration.fixture)
        }
        return [
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
            ),
        ]
    }

    /// Semana completa para probar el score semanal.
    public static var week: [ActivitySnapshot] {
        var result: [ActivitySnapshot] = today
        for dayOffset in -4 ... -1 {
            result.append(contentsOf: [
                ActivitySnapshot(
                    title: "Despertar",
                    category: .despertar,
                    startDate: at(6, 30, dayOffset: dayOffset),
                    priority: .esencial,
                    status: .completada
                ),
                ActivitySnapshot(
                    title: "Almuerzo",
                    category: .comida,
                    startDate: at(13, 0, dayOffset: dayOffset),
                    status: dayOffset % 2 == 0 ? .completada : .pendiente
                ),
                ActivitySnapshot(
                    title: "Lectura",
                    category: .lectura,
                    startDate: at(21, 0, dayOffset: dayOffset),
                    status: .completada
                ),
            ])
        }
        return result
    }

    public static var evaluableCount: Int {
        today.filter(\.isEvaluable).count
    }

    public static var completedCount: Int {
        today.filter(\.isCompleted).count
    }

    public static var dayProgress: Double {
        guard evaluableCount > 0 else { return 0 }
        return Double(completedCount) / Double(evaluableCount)
    }

    public static var nextActivity: ActivitySnapshot? {
        // Bajo UI tests el "ahora" es la fecha ancla fija, no el reloj del simulador.
        let reference = UITestConfiguration.isActive ? ScreenshotFixtures.anchorDate : Date()
        return today.filter { $0.startDate > reference && !$0.isCompleted }
            .min { $0.startDate < $1.startDate }
    }

    public static var todayLongDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE d 'de' MMMM"
        return formatter.string(from: Date()).capitalized
    }

    public static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
