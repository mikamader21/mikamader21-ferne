import Foundation
import UserNotifications

/// Proyección `Sendable` de `UNNotificationSettings`.
///
/// Existe porque `UNNotificationSettings` no es `Sendable` y no puede cruzar un
/// límite de aislamiento. La conversión ocurre dentro del callback del sistema y
/// solo este valor sale hacia la app.
public struct NotificationHealth: Sendable, Equatable {
    /// Estado de autorización, con nombres propios en lugar del enum de Apple.
    public enum Authorization: String, Sendable {
        case notDetermined
        case denied
        case authorized
        case provisional
        case ephemeral
        case unknown

        init(_ status: UNAuthorizationStatus) {
            switch status {
            case .notDetermined: self = .notDetermined
            case .denied: self = .denied
            case .authorized: self = .authorized
            case .provisional: self = .provisional
            case .ephemeral: self = .ephemeral
            @unknown default: self = .unknown
            }
        }

        /// `true` si iOS entregará las alertas. Es la única base honesta para
        /// afirmar en la UI que algo va a sonar (§8.1).
        public var allowsDelivery: Bool {
            self == .authorized || self == .provisional || self == .ephemeral
        }

        public var displayText: String {
            switch self {
            case .notDetermined: "Sin decidir todavía"
            case .denied: "Desactivadas en iOS"
            case .authorized: "Activadas"
            case .provisional: "Activadas en silencio"
            case .ephemeral: "Activadas temporalmente"
            case .unknown: "Estado desconocido"
            }
        }
    }

    public let authorization: Authorization
    public let alertsEnabled: Bool
    public let soundEnabled: Bool
    public let badgeEnabled: Bool
    public let timeSensitiveEnabled: Bool
    /// Resumen programado: si está activo, una alerta puede llegar horas más tarde.
    public let scheduledSummaryEnabled: Bool

    public init(
        authorization: Authorization,
        alertsEnabled: Bool,
        soundEnabled: Bool,
        badgeEnabled: Bool,
        timeSensitiveEnabled: Bool,
        scheduledSummaryEnabled: Bool
    ) {
        self.authorization = authorization
        self.alertsEnabled = alertsEnabled
        self.soundEnabled = soundEnabled
        self.badgeEnabled = badgeEnabled
        self.timeSensitiveEnabled = timeSensitiveEnabled
        self.scheduledSummaryEnabled = scheduledSummaryEnabled
    }

    /// `true` si FERNÉ puede afirmar que una alerta sonará.
    public var canPromiseDelivery: Bool {
        authorization.allowsDelivery && alertsEnabled
    }
}
