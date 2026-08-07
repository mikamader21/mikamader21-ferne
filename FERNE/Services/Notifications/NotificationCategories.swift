import Foundation
import UserNotifications

/// Categorías y acciones de las notificaciones (MASTER_SPEC §8.2).
///
/// Dos momentos distintos, dos categorías:
/// - **Recordatorio** (llega a la hora): Empezar · Reprogramar · Hoy no.
/// - **Cierre** (llega al terminar la ventana): pregunta por el resultado.
public enum NotificationCategories {
    public static let reminder = "ferne.reminder"
    public static let completion = "ferne.completion"

    public enum Action {
        public static let start = "ferne.action.start"
        public static let reschedule = "ferne.action.reschedule"
        public static let skipToday = "ferne.action.skipToday"
        public static let done = "ferne.action.done"
        public static let partial = "ferne.action.partial"
        public static let notDone = "ferne.action.notDone"
    }

    /// Clave del `userInfo` con el UUID de la actividad.
    public static let activityIDKey = "ferne.activityID"

    public static func registerAll(on center: UNUserNotificationCenter) {
        center.setNotificationCategories([reminderCategory, completionCategory])
    }

    private static var reminderCategory: UNNotificationCategory {
        UNNotificationCategory(
            identifier: reminder,
            actions: [
                UNNotificationAction(identifier: Action.start, title: "Empezar", options: []),
                UNNotificationAction(identifier: Action.reschedule, title: "Reprogramar", options: [.foreground]),
                UNNotificationAction(identifier: Action.skipToday, title: "Hoy no", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
    }

    private static var completionCategory: UNNotificationCategory {
        UNNotificationCategory(
            identifier: completion,
            actions: [
                UNNotificationAction(identifier: Action.done, title: "Sí, cumplido", options: []),
                UNNotificationAction(identifier: Action.partial, title: "Parcialmente", options: []),
                UNNotificationAction(identifier: Action.reschedule, title: "Reprogramar", options: [.foreground]),
                UNNotificationAction(identifier: Action.notDone, title: "No lo hice", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
    }
}
