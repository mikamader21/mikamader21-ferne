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

    /// `true` mientras la app está en primer plano. Las animaciones ambientales se
    /// detienen en segundo plano: no tiene sentido gastar batería animando algo
    /// que nadie ve.
    public private(set) var isForeground = true

    private var transitionTask: Task<Void, Never>?

    public func refresh() {
        guard UITestConfiguration.forcedPhase == nil else { return }
        let newPhase = provider.currentPhase
        if newPhase != phase {
            // La transición día/noche se anima entre 0.8 y 1.2 s.
            withAnimation(.easeInOut(duration: FerneMotion.phaseTransition)) {
                phase = newPhase
            }
        }
        scheduleNextTransition()
    }

    public func enterForeground() {
        isForeground = true
        refresh()
    }

    public func enterBackground() {
        isForeground = false
        transitionTask?.cancel()
        transitionTask = nil
    }

    /// Programa un único despertar en la frontera siguiente, en lugar de sondear el
    /// reloj. Se recalcula en cada refresco, así que un cambio de zona horaria lo
    /// corrige solo.
    private func scheduleNextTransition() {
        transitionTask?.cancel()
        guard UITestConfiguration.forcedPhase == nil,
              let provider = provider as? SystemDayPhaseProvider,
              let next = provider.nextTransition
        else { return }

        let delay = next.timeIntervalSince(provider.now)
        guard delay > 0 else { return }

        transitionTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay + 1))
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.refresh() }
        }
    }

    /// Reacciona a un cambio de zona horaria del sistema.
    public func timeZoneDidChange() {
        refresh()
    }

    public func greeting(for name: String) -> String {
        phase.greeting(name: name)
    }

    /// Controlador fijo para previews y para la QA visual día/noche.
    public static func preview(_ phase: DayPhase) -> ThemeController {
        ThemeController(provider: FixedDayPhaseProvider(phase: phase))
    }
}
