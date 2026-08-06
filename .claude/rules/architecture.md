# Regla · Arquitectura

Aplica a: `FERNE/**`

## Capas

| Capa | Puede importar | Nunca importa |
|---|---|---|
| `Domain/` | Foundation | SwiftUI, SwiftData, UIKit |
| `Data/` | Foundation, SwiftData, CloudKit, Domain | SwiftUI |
| `Services/` | Frameworks de Apple, Domain | Features |
| `DesignSystem/` | SwiftUI, Domain | Data, Features |
| `Features/` | Todo lo anterior | Otro Feature (usar Domain como intermediario) |

`Scripts/design-guard.sh` verifica la pureza de `Domain/`. Si falla, la capa está rota.

## Reglas

1. Las reglas de negocio **no** viven en las vistas. Una vista no calcula un score ni decide si algo es evaluable.
2. No crear protocolos ni capas de abstracción sin al menos dos implementaciones reales o una necesidad de prueba concreta.
3. Las dependencias se inyectan (`DayPhaseProviding`, repositorios). Nada de singletons ocultos salvo `Haptics.shared`, que es un envoltorio de UIKit.
4. Nada de `Date()` implícito en el dominio: el `Calendar` y la fecha se inyectan siempre.
5. Un tipo nuevo del dominio va a `Domain/Entities/` como `struct` puro; el `@Model` de SwiftData lo proyecta, no lo sustituye.

## Prohibido

- Backend, red o SDK de terceros en el MVP.
- `Supabase`, `Firebase`, analytics.
- Lógica de presentación dentro de `Domain/`.
