import Foundation
import UserNotifications

/// Programa, cancela y reprograma las alertas locales de una actividad.
///
/// Reglas que hacen que esto sea fiable (MASTER_SPEC §8.2):
/// - **Identificadores deterministas** derivados del UUID de la actividad. Con un
///   UUID aleatorio por notificación sería imposible cancelarla al editar, y Fer
///   recibiría la alerta vieja y la nueva.
/// - **Cancelar antes de programar**, siempre. Es la única forma de no duplicar.
/// - `DateComponents` con el `Calendar` y `TimeZone` locales, para que un viaje no
///   desplace las alertas.
/// - Funciona sin conexión: son notificaciones locales, no push.
@MainActor
public struct NotificationScheduler {
    private let center: UNUserNotificationCenter
    private let calendar: Calendar

    public init(
        center: UNUserNotificationCenter = .current(),
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.center = center
        self.calendar = calendar
    }

    // MARK: - Identificadores

    /// Recordatorio con `index` correspondiente a cada `reminderOffset`.
    public static func reminderID(for activityID: UUID, index: Int) -> String {
        "\(activityID.uuidString)#reminder\(index)"
    }

    /// Pregunta de cierre, al terminar la ventana.
    public static func completionID(for activityID: UUID) -> String {
        "\(activityID.uuidString)#completion"
    }

    public static func prefix(for activityID: UUID) -> String {
        "\(activityID.uuidString)#"
    }

    // MARK: - Programación

    /// Cancela lo anterior y programa lo nuevo. Llamar siempre así, nunca solo programar.
    public func sync(_ activity: ActivitySnapshot, soundID: String?) async {
        cancel(activityID: activity.id)

        guard await isAuthorized() else {
            FerneLog.notifications.info("Sin permiso: no se programa nada para \(activity.id.uuidString, privacy: .public)")
            return
        }
        guard activity.status.isOpen else { return }

        let sound = notificationSound(for: soundID)

        for (index, offset) in activity.reminderOffsets.enumerated() {
            let fireDate = activity.startDate.addingTimeInterval(-offset)
            guard fireDate > Date() else { continue }
            await add(
                id: Self.reminderID(for: activity.id, index: index),
                title: activity.title,
                body: reminderBody(for: activity, offset: offset),
                category: NotificationCategories.reminder,
                date: fireDate,
                sound: sound,
                activityID: activity.id
            )
        }

        // Pregunta de cierre: sin ella, una actividad vencida se quedaría en
        // "sin confirmar" para siempre y el score nunca sabría qué pasó.
        let closingDate = activity.windowEnd(calendar: calendar)
        if closingDate > Date() {
            await add(
                id: Self.completionID(for: activity.id),
                title: activity.title,
                body: "¿\(activity.category.completionVerb)?",
                category: NotificationCategories.completion,
                date: closingDate,
                sound: sound,
                activityID: activity.id
            )
        }
    }

    /// Elimina todas las alertas de una actividad, pendientes y ya entregadas.
    public func cancel(activityID: UUID) {
        let prefix = Self.prefix(for: activityID)
        // Hasta 8 recordatorios por actividad, más la pregunta de cierre.
        var ids = (0 ..< 8).map { Self.reminderID(for: activityID, index: $0) }
        ids.append(Self.completionID(for: activityID))
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
        FerneLog.notifications.info("Canceladas las alertas con prefijo \(prefix, privacy: .public)")
    }

    /// Elimina lo que quedó de actividades que ya no existen.
    public func reconcile(with liveIDs: Set<UUID>) async {
        let pending = await center.pendingNotificationRequests()
        let orphaned = pending
            .map(\.identifier)
            .filter { identifier in
                guard let uuidPart = identifier.split(separator: "#").first,
                      let uuid = UUID(uuidString: String(uuidPart))
                else { return true }
                return !liveIDs.contains(uuid)
            }
        guard !orphaned.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: orphaned)
        FerneLog.notifications.info("Reconciliación: \(orphaned.count, privacy: .public) alertas huérfanas eliminadas")
    }

    // MARK: - Estado

    public func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    /// Estado real del sistema, para el centro de salud. **La UI no debe prometer
    /// entrega sin consultar esto** (§8.1).
    public func currentSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }

    public func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }

    /// La próxima alerta programada, con su fecha real de disparo.
    public func nextScheduled() async -> (identifier: String, date: Date)? {
        let pending = await center.pendingNotificationRequests()
        let dated = pending.compactMap { request -> (String, Date)? in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let date = trigger.nextTriggerDate()
            else { return nil }
            return (request.identifier, date)
        }
        return dated.min { $0.1 < $1.1 }
    }

    // MARK: - Interno

    private func add(
        id: String,
        title: String,
        body: String,
        category: String,
        date: Date,
        sound: UNNotificationSound?,
        activityID: UUID
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = category
        content.sound = sound
        content.userInfo = [NotificationCategories.activityIDKey: activityID.uuidString]

        // Componentes con calendario y zona horaria locales: si Fer viaja, la alerta
        // se mantiene en la hora que ella eligió.
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.timeZone = calendar.timeZone

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            FerneLog.notifications.error("No se pudo programar \(id, privacy: .public)")
        }
    }

    /// Solo se ofrece un sonido si su archivo existe de verdad en el bundle.
    private func notificationSound(for soundID: String?) -> UNNotificationSound? {
        guard let soundID, soundID != SoundLibrary.silentSoundID else {
            return soundID == SoundLibrary.silentSoundID ? nil : .default
        }
        guard let sound = SoundLibrary.sound(withID: soundID), sound.isAvailable else {
            return .default
        }
        return UNNotificationSound(named: UNNotificationSoundName(sound.fileName))
    }

    private func reminderBody(for activity: ActivitySnapshot, offset: TimeInterval) -> String {
        let minutes = Int(offset / 60)
        if minutes <= 0 {
            return "Es la hora. ¿Empezamos?"
        }
        return "En \(minutes) min. ¿Empezamos?"
    }
}
