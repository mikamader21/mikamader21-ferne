import Foundation
import SwiftData
import UserNotifications

/// Recibe las respuestas a las notificaciones y las aplica a la actividad.
///
/// Las mismas acciones funcionan desde la notificación y desde dentro de la app:
/// ambas terminan llamando a `ActivityRepository`.
@MainActor
public final class NotificationResponder: NSObject, UNUserNotificationCenterDelegate {
    private let container: ModelContainer

    public init(container: ModelContainer) {
        self.container = container
        super.init()
    }

    /// Mostrar la alerta aunque la app esté abierta: si Fer está mirando otra
    /// pestaña, el aviso sigue siendo útil.
    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    public func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let info = response.notification.request.content.userInfo
        guard let raw = info[NotificationCategories.activityIDKey] as? String,
              let id = UUID(uuidString: raw)
        else { return }

        let context = ModelContext(container)
        let repository = ActivityRepository(context: context)
        guard let record = repository.find(id: id) else { return }

        switch response.actionIdentifier {
        case NotificationCategories.Action.start:
            repository.start(record)
        case NotificationCategories.Action.done:
            repository.complete(record)
        case NotificationCategories.Action.partial:
            repository.markPartial(record)
        case NotificationCategories.Action.notDone, NotificationCategories.Action.skipToday:
            repository.markSkipped(record)
        case NotificationCategories.Action.reschedule:
            // Reprogramar necesita elegir una hora, así que solo se abre la app.
            // Mover a ciegas sería decidir por Fer.
            break
        default:
            break
        }
    }
}
