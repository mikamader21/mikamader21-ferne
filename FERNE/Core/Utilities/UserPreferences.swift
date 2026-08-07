import Foundation
import Observation

/// Preferencias de Fer, respondidas en el onboarding y editables desde Perfil.
///
/// Viven en `UserDefaults` (§3.1: `AppStorage` para preferencias simples), no en
/// SwiftData: son ajustes, no datos de dominio.
@MainActor
@Observable
public final class UserPreferences {
    public enum Key {
        public static let hasCompletedOnboarding = "ferne.onboarding.completed"
        public static let preferredName = "ferne.user.preferredName"
        public static let selectedCategories = "ferne.user.categories"
        public static let wakeTime = "ferne.schedule.wake"
        public static let breakfastTime = "ferne.schedule.breakfast"
        public static let lunchTime = "ferne.schedule.lunch"
        public static let dinnerTime = "ferne.schedule.dinner"
        public static let sleepTime = "ferne.schedule.sleep"
        public static let wantsWakeReminder = "ferne.schedule.wakeReminder"
        public static let wantsDailyMessage = "ferne.tone.dailyMessage"
        public static let wantsGentleReminders = "ferne.tone.gentleReminders"
        public static let preferredSoundID = "ferne.sound.preferred"
        public static let hapticsEnabled = "ferne.haptics.enabled"
        public static let notificationsRequested = "ferne.notifications.requested"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Onboarding

    public var hasCompletedOnboarding: Bool {
        get {
            // Bajo UI tests con `-FERNEResetOnboarding 1` siempre se muestra, para
            // poder capturarlo sin depender del estado previo del simulador.
            if UITestConfiguration.resetsOnboarding {
                return false
            }
            return defaults.bool(forKey: Key.hasCompletedOnboarding)
        }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    public var preferredName: String {
        get {
            let stored = defaults.string(forKey: Key.preferredName) ?? ""
            return stored.isEmpty ? "Fer" : stored
        }
        set { defaults.set(newValue.trimmingCharacters(in: .whitespaces), forKey: Key.preferredName) }
    }

    /// Categorías que Fer eligió organizar. Vacío = ninguna elegida todavía.
    public var selectedCategories: Set<ActivityCategory> {
        get {
            let raws = defaults.stringArray(forKey: Key.selectedCategories) ?? []
            return Set(raws.compactMap(ActivityCategory.init(rawValue:)))
        }
        set { defaults.set(newValue.map(\.rawValue).sorted(), forKey: Key.selectedCategories) }
    }

    // MARK: - Horarios

    public var wakeTime: Date? {
        get { time(for: Key.wakeTime) }
        set { setTime(newValue, for: Key.wakeTime) }
    }

    public var breakfastTime: Date? {
        get { time(for: Key.breakfastTime) }
        set { setTime(newValue, for: Key.breakfastTime) }
    }

    public var lunchTime: Date? {
        get { time(for: Key.lunchTime) }
        set { setTime(newValue, for: Key.lunchTime) }
    }

    public var dinnerTime: Date? {
        get { time(for: Key.dinnerTime) }
        set { setTime(newValue, for: Key.dinnerTime) }
    }

    public var sleepTime: Date? {
        get { time(for: Key.sleepTime) }
        set { setTime(newValue, for: Key.sleepTime) }
    }

    public var wantsWakeReminder: Bool {
        get { defaults.bool(forKey: Key.wantsWakeReminder) }
        set { defaults.set(newValue, forKey: Key.wantsWakeReminder) }
    }

    // MARK: - Tono y avisos

    public var wantsDailyMessage: Bool {
        get { defaults.object(forKey: Key.wantsDailyMessage) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.wantsDailyMessage) }
    }

    public var wantsGentleReminders: Bool {
        get { defaults.object(forKey: Key.wantsGentleReminders) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.wantsGentleReminders) }
    }

    public var preferredSoundID: String {
        get { defaults.string(forKey: Key.preferredSoundID) ?? SoundLibrary.systemSoundID }
        set { defaults.set(newValue, forKey: Key.preferredSoundID) }
    }

    public var hapticsEnabled: Bool {
        get { defaults.object(forKey: Key.hapticsEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.hapticsEnabled) }
    }

    public var notificationsRequested: Bool {
        get { defaults.bool(forKey: Key.notificationsRequested) }
        set { defaults.set(newValue, forKey: Key.notificationsRequested) }
    }

    // MARK: - Restablecer

    public func resetOnboarding() {
        defaults.set(false, forKey: Key.hasCompletedOnboarding)
    }

    /// Borra TODAS las preferencias. Las actividades se borran aparte, en el repositorio.
    public func resetEverything() {
        let keys = [
            Key.hasCompletedOnboarding, Key.preferredName, Key.selectedCategories,
            Key.wakeTime, Key.breakfastTime, Key.lunchTime, Key.dinnerTime, Key.sleepTime,
            Key.wantsWakeReminder, Key.wantsDailyMessage, Key.wantsGentleReminders,
            Key.preferredSoundID, Key.hapticsEnabled, Key.notificationsRequested
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Helpers

    private func time(for key: String) -> Date? {
        guard let seconds = defaults.object(forKey: key) as? Double else { return nil }
        return Calendar.ferneDefault.date(
            bySettingHour: Int(seconds) / 3600,
            minute: (Int(seconds) % 3600) / 60,
            second: 0,
            of: Date()
        )
    }

    private func setTime(_ date: Date?, for key: String) {
        guard let date else {
            defaults.removeObject(forKey: key)
            return
        }
        let parts = Calendar.ferneDefault.dateComponents([.hour, .minute], from: date)
        defaults.set(Double((parts.hour ?? 0) * 3600 + (parts.minute ?? 0) * 60), forKey: key)
    }
}
