import OSLog

/// Registro de la app.
///
/// **Nunca** registrar contenido personal: títulos de actividades, notas, mensajes,
/// prompts de IA o respuestas (MASTER_SPEC §10.3, §13). Se registran identificadores,
/// categorías y estados; jamás texto escrito por la usuaria.
public enum FerneLog {
    private static let subsystem = "com.ferne.app"

    public static let app = Logger(subsystem: subsystem, category: "app")
    public static let data = Logger(subsystem: subsystem, category: "data")
    public static let notifications = Logger(subsystem: subsystem, category: "notifications")
    public static let score = Logger(subsystem: subsystem, category: "score")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
}
