import Foundation
import SwiftData
import UserNotifications

/// Recibe las respuestas a las notificaciones y las aplica a la actividad.
///
/// **Concurrencia.** Los métodos de `UNUserNotificationCenterDelegate` los invoca el
/// sistema desde un contexto no aislado, y `UNNotification`,
/// `UNNotificationResponse` y `UNUserNotificationCenter` no son `Sendable`. Por eso
/// los callbacks son `nonisolated`: dentro se extraen **solo valores `Sendable`**
/// —el identificador de acción y el UUID de la actividad— y son esos los que cruzan
/// hacia el `MainActor`. Ningún objeto de Apple atraviesa el límite de aislamiento.
///
/// La clase sí es `@MainActor` (y por tanto `Sendable`) para poder asignarla como
/// `delegate` sin que el compilador tenga que enviar un valor no seguro.
///
/// Las mismas acciones funcionan desde la notificación y desde dentro de la app:
/// ambas terminan llamando a `ActivityRepository`.
@MainActor
public final class NotificationResponder: NSObject, UNUserNotificationCenterDelegate {
    /// `ModelContainer` es `Sendable`, así que puede leerse desde los callbacks
    /// no aislados sin sacarlo del actor.
    private nonisolated let container: ModelContainer

    public nonisolated init(container: ModelContainer) {
        self.container = container
        super.init()
    }

    // MARK: - Callbacks del sistema (no aislados)

    /// Mostrar la alerta aunque la app esté abierta: si Fer está en otra pestaña,
    /// el aviso sigue siendo útil. Las opciones se devuelven **una sola vez**.
    public nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    /// Se extraen los datos de forma síncrona y se cruza al `MainActor` con dos
    /// valores primitivos. La respuesta se completa **exactamente una vez**, al
    /// volver de `apply`.
    public nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let action = response.actionIdentifier
        let rawID = response.notification.request.content
            .userInfo[NotificationCategories.activityIDKey] as? String

        guard let rawID, let activityID = UUID(uuidString: rawID) else {
            FerneLog.notifications.info("Respuesta sin identificador de actividad; se ignora")
            return
        }

        await apply(action: action, activityID: activityID)
    }

    // MARK: - Aplicación del cambio (MainActor)

    /// Recibe únicamente valores `Sendable`. Es el único punto que toca SwiftData.
    private func apply(action: String, activityID: UUID) {
        let context = ModelContext(container)
        let repository = ActivityRepository(context: context)
        guard let record = repository.find(id: activityID) else { return }

        switch action {
        case NotificationCategories.Action.start:
            repository.start(record)
        case NotificationCategories.Action.done:
            repository.complete(record)
        case NotificationCategories.Action.partial:
            repository.markPartial(record)
        case NotificationCategories.Action.notDone, NotificationCategories.Action.skipToday:
            repository.markSkipped(record)
        case NotificationCategories.Action.reschedule:
            // Reprogramar exige elegir una hora, así que solo se abre la app.
            // Mover a ciegas sería decidir por Fer.
            break
        default:
            break
        }
    }
}
