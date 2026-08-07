import Observation
import SwiftUI

/// Mantiene el tema vigente y lo actualiza cuando cambia la franja horaria.
///
/// Se refresca al volver a primer plano y en un intervalo prudente; no usa un
/// temporizador agresivo porque el cambio de franja ocurre como mucho tres veces al día.
@MainActor
@Observable
public final class ThemeController {
    public private(set) var phase: DayPhase
    private let provider: any DayPhaseProviding

    public init(provider: any DayPhaseProviding = SystemDayPhaseProvider()) {
        #if DEBUG
            // Bajo UI tests la franja se fija por argumento de lanzamiento: las capturas
            // de mañana, tarde y noche no pueden depender de la hora del simulador.
            // `ScreenshotFixtures` solo existe en Debug, de ahí el guardado.
            if let forced = UITestConfiguration.forcedPhase {
                self.provider = FixedDayPhaseProvider(phase: forced, date: ScreenshotFixtures.anchorDate)
                phase = forced
            } else {
                self.provider = provider
                phase = provider.currentPhase
            }
        #else
            self.provider = provider
            phase = provider.currentPhase
        #endif
    }

    public var theme: FerneTheme {
        .theme(for: phase)
    }

    /// "Ahora" según la app. Bajo UI tests es la fecha ancla fija, para que las
    /// capturas no dependan del reloj del simulador.
    public var referenceDate: Date {
        provider.now
    }

    public func refresh() {
        guard UITestConfiguration.forcedPhase == nil else { return }
        let newPhase = provider.currentPhase
        guard newPhase != phase else { return }
        phase = newPhase
    }

    public func greeting(for name: String) -> String {
        phase.greeting(name: name)
    }

    /// Controlador fijo para previews y para la QA visual día/noche.
    public static func preview(_ phase: DayPhase) -> ThemeController {
        ThemeController(provider: FixedDayPhaseProvider(phase: phase))
    }
}
