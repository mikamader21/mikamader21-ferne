import Foundation
#if canImport(AlarmKit)
import AlarmKit
#endif

/// Puerta de entrada a AlarmKit.
///
/// **Este tipo existe antes que el código de alarmas a propósito.** Establece el patrón
/// obligatorio para la Fase 4 y garantiza desde hoy que la ausencia de AlarmKit nunca
/// impida compilar.
///
/// Tres capas de protección, y las tres son necesarias:
///
/// 1. **`#if canImport(AlarmKit)`** — si el SDK del runner no trae el framework, el `import`
///    ni siquiera se evalúa. Sin esto, un Xcode más antiguo rompería la compilación.
/// 2. **`if #available(...)`** — el framework puede existir en el SDK pero no en la versión
///    de iOS del dispositivo. Compilar no es lo mismo que poder ejecutar.
/// 3. **Fallback completo con `UserNotifications`** — aunque las dos anteriores pasen, el
///    usuario puede no haber concedido el permiso, o Apple puede no haber aprobado el
///    entitlement. La app tiene que seguir avisando.
///
/// Regla que no se negocia (MASTER_SPEC §8.2): **nunca** se promete una alarma que el
/// sistema no puede garantizar. Ver `docs/NOTIFICATIONS.md`.
public enum AlarmCapability {

    /// Estado real de AlarmKit en este dispositivo, ahora mismo.
    public enum Status: Equatable, Sendable {
        /// Disponible y utilizable para alarmas prominentes.
        case available
        /// El framework no está en el SDK con el que se compiló.
        case notCompiledIn
        /// El framework existe pero la versión de iOS no lo soporta.
        case unsupportedOS
        /// Disponible, pero el permiso no está concedido.
        case notAuthorized

        /// Texto para el centro de salud de notificaciones (pantalla 25).
        /// Honesto: si no va a sonar como alarma, se dice.
        public var displayText: String {
            switch self {
            case .available:     "Alarmas prominentes disponibles"
            case .notCompiledIn: "No disponible en esta versión de la app"
            case .unsupportedOS: "Tu versión de iOS no admite alarmas prominentes"
            case .notAuthorized: "Sin permiso para alarmas prominentes"
            }
        }

        /// `true` si hay que recurrir a una notificación local.
        public var requiresFallback: Bool { self != .available }
    }

    /// `true` si el framework estaba presente al compilar.
    public static var isCompiledIn: Bool {
        #if canImport(AlarmKit)
        return true
        #else
        return false
        #endif
    }

    /// Estado actual. **No asume nada**: comprueba compilación y disponibilidad de OS.
    ///
    /// La comprobación de autorización llega en la Fase 4, cuando exista el gestor de
    /// alarmas. Hasta entonces devuelve `.available` si el sistema lo soporta, y el
    /// llamador debe seguir usando el fallback.
    public static var status: Status {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            return .available
        } else {
            return .unsupportedOS
        }
        #else
        return .notCompiledIn
        #endif
    }

    /// Decide la vía de entrega de una actividad.
    ///
    /// Solo `Priority.esencial` (despertar y dormir) opta a alarma prominente. Todo lo demás
    /// va por notificación local, aunque AlarmKit esté disponible: convertir un recordatorio
    /// de lectura en una alarma que no se puede silenciar sería hostil.
    public static func deliveryRoute(for priority: Priority) -> DeliveryRoute {
        guard priority.deservesProminentAlarm else { return .localNotification }
        return status == .available ? .prominentAlarm : .localNotification
    }

    public enum DeliveryRoute: String, Sendable {
        /// AlarmKit. Suena aunque el dispositivo esté en silencio.
        case prominentAlarm
        /// `UNUserNotificationCenter`. Es el camino por defecto y el fallback universal.
        case localNotification
    }
}
