import Foundation

/// Respuestas del onboarding mientras se rellenan. Solo se escriben en
/// `UserPreferences` al pulsar "Comenzar" en la última página: si Fer abandona
/// a mitad, no queda nada a medias.
struct OnboardingDraft {
    /// Las nueve categorías que se ofrecen para organizar (§2 del encargo).
    static let offeredCategories: [ActivityCategory] = [
        .despertar, .comida, .gym, .trabajo, .live, .lectura, .pago, .dormir, .personal
    ]

    var name: String = "Fer"
    var categories: Set<ActivityCategory> = []

    var wakeTime: Date = OnboardingDraft.defaultTime(hour: 7)
    var wantsWakeReminder: Bool = true

    var wantsBreakfast: Bool = false
    var breakfastTime: Date = OnboardingDraft.defaultTime(hour: 8)
    var wantsLunch: Bool = false
    var lunchTime: Date = OnboardingDraft.defaultTime(hour: 13)
    var wantsDinner: Bool = false
    var dinnerTime: Date = OnboardingDraft.defaultTime(hour: 20)
    var wantsSleep: Bool = false
    var sleepTime: Date = OnboardingDraft.defaultTime(hour: 0)

    var wantsDailyMessage: Bool = true
    var wantsGentleReminders: Bool = true
    var hapticsEnabled: Bool = true
    var soundID: String = SoundLibrary.systemSoundID

    /// Nombre ya limpio. Si Fer no escribe nada, se queda con la sugerencia.
    var resolvedName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Fer" : trimmed
    }

    @MainActor
    func apply(to preferences: UserPreferences) {
        preferences.preferredName = resolvedName
        preferences.selectedCategories = categories
        preferences.wakeTime = wakeTime
        preferences.wantsWakeReminder = wantsWakeReminder
        preferences.breakfastTime = wantsBreakfast ? breakfastTime : nil
        preferences.lunchTime = wantsLunch ? lunchTime : nil
        preferences.dinnerTime = wantsDinner ? dinnerTime : nil
        preferences.sleepTime = wantsSleep ? sleepTime : nil
        preferences.wantsDailyMessage = wantsDailyMessage
        preferences.wantsGentleReminders = wantsGentleReminders
        preferences.hapticsEnabled = hapticsEnabled
        preferences.preferredSoundID = soundID
    }

    private static func defaultTime(hour: Int) -> Date {
        Calendar.ferneDefault.date(
            bySettingHour: hour, minute: 0, second: 0, of: Date()
        ) ?? Date()
    }
}
