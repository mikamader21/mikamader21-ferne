# Regla · Estilo Swift

Aplica a: `**/*.swift`

- Swift 6, concurrencia estricta. El código de UI es `@MainActor`.
- Indentación 4 espacios, ancho máximo 140 (ver `.swiftformat`).
- `force_cast`, `force_try` → error. `!` de desempaquetado → warning y debe justificarse en comentario.
- Nombres en inglés para el código; textos visibles en español.
- Documentar el **porqué**, no el qué. Un comentario que repite el nombre de la función sobra.
- Todo tipo público del dominio: `Sendable`, `Codable` cuando se persista, `Hashable` cuando entre en colecciones.
- `switch` exhaustivo sin `default` cuando el enum es propio: así el compilador avisa al añadir un caso.
- Prohibido `print(`. Usar `FerneLog`, sin datos personales.
