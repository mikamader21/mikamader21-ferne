import Foundation

/// Biblioteca de sonidos de FERNÉ (MASTER_SPEC §8.3).
///
/// Los seis sonidos están declarados, pero los archivos de audio **aún no existen**
/// (ver `FERNE/Resources/Sounds/README.md`). `isAvailable` refleja la realidad del
/// bundle: la app nunca debe prometer un sonido que no puede reproducir.
public struct FerneSound: Identifiable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let fileName: String

    public init(id: String, displayName: String, fileName: String) {
        self.id = id
        self.displayName = displayName
        self.fileName = fileName
    }

    /// `true` solo si el archivo existe realmente en el bundle.
    public var isAvailable: Bool {
        Bundle.main.url(forResource: (fileName as NSString).deletingPathExtension, withExtension: "caf") != nil
    }
}

public enum SoundLibrary {
    public static let amanecer  = FerneSound(id: "amanecer",  displayName: "Amanecer",  fileName: "amanecer.caf")
    public static let campanita = FerneSound(id: "campanita", displayName: "Campanita", fileName: "campanita.caf")
    public static let destello  = FerneSound(id: "destello",  displayName: "Destello",  fileName: "destello.caf")
    public static let flor      = FerneSound(id: "flor",      displayName: "Flor",      fileName: "flor.caf")
    public static let luna      = FerneSound(id: "luna",      displayName: "Luna",      fileName: "luna.caf")
    public static let sueno     = FerneSound(id: "sueno",     displayName: "Sueño",     fileName: "sueno.caf")

    /// Identificadores especiales, siempre disponibles.
    public static let systemSoundID = "sistema"
    public static let silentSoundID = "silencio"

    public static let all: [FerneSound] = [amanecer, campanita, destello, flor, luna, sueno]

    public static func sound(withID id: String) -> FerneSound? {
        all.first { $0.id == id }
    }

    /// Sonidos que realmente pueden reproducirse ahora mismo.
    public static var available: [FerneSound] { all.filter(\.isAvailable) }
}
