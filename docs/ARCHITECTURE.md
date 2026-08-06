# Arquitectura

## Decisión: arquitectura por features con dominio puro

FERNÉ separa cuatro capas. La restricción más importante y la única verificada automáticamente es que **`Domain/` sea Foundation puro**.

### Por qué el dominio es puro

Sin SwiftUI ni SwiftData en `Domain/`, el motor de score y todas las reglas de fecha pueden compilarse y probarse **sin Xcode y sin simulador** (`Scripts/verify-logic.sh`). Eso permite:

- Verificar los ocho casos obligatorios de §9.4 en cualquier máquina y en CI.
- Detectar regresiones en segundos en lugar de minutos.
- Evitar que la lógica de negocio se filtre a las vistas, que es la forma habitual de que una app se vuelva imposible de probar.

`Scripts/design-guard.sh` falla si alguien introduce `import SwiftUI` en `Domain/`.

### Flujo de dependencias

```
Features  ──▶ DesignSystem ──▶ Domain
   │              │              ▲
   │              └──────────────┤
   ├──▶ Services ────────────────┤
   └──▶ Data ────────────────────┘
```

Nada apunta hacia `Features`. Un feature nunca importa otro feature.

## Modelo de datos: `struct` puro + `@Model`

Cada entidad existe dos veces, a propósito:

| | Dónde | Para qué |
|---|---|---|
| `ActivitySnapshot` (`struct`) | `Domain/Entities/` | Reglas, score, pruebas. Inmutable, `Sendable`, `Codable`. |
| `Activity` (`@Model`) | `Data/Persistence/` (Fase 1) | Persistencia SwiftData, relaciones, migraciones. |

La proyección `toSnapshot()` va en una sola dirección. El dominio jamás conoce SwiftData.

**Coste aceptado:** un poco de duplicación de campos. **Beneficio:** el dominio es testeable sin contenedor y los cambios de persistencia no arrastran las reglas de negocio.

## Inyección de dependencias

Sin framework de DI. Se usa lo que SwiftUI ya ofrece:

- `@Environment` para el tema (`ferneTheme`) y el `ThemeController`.
- Protocolos pequeños donde la prueba lo exige: `DayPhaseProviding` permite fijar la franja horaria en previews y tests sin tocar el reloj del sistema.
- `Calendar` inyectado siempre en el dominio. **Nunca `Date()` implícito** dentro de una regla.

No se crean protocolos "por si acaso". Un protocolo sin segunda implementación ni necesidad de prueba es ruido.

## Concurrencia

Swift 6 con `SWIFT_STRICT_CONCURRENCY=complete`.

- La UI y los controladores observables son `@MainActor`.
- Los tipos del dominio son `Sendable` (`struct` de valor, sin referencias).
- Los servicios que tocan el sistema (`Haptics`) son `@MainActor`.

## Navegación

`TabView` con cuatro pestañas (§5) y un `NavigationStack` por pestaña. Agenda y Rutinas se alcanzan desde Inicio, no desde la barra: la barra tiene cuatro destinos, no seis.

El Splash se presenta sobre el `TabView` y se retira solo; no es un destino de navegación.

## Qué NO se hizo, y por qué

- **Sin Coordinator ni Router.** Cuatro pestañas y pilas poco profundas no lo justifican. Se añadirá si un flujo real lo pide.
- **Sin Repository protocol todavía.** Llega en la Fase 1, cuando exista SwiftData y haya algo que abstraer.
- **Sin módulos SwiftPM separados.** Un solo target mantiene el build simple; la separación se garantiza con el guardián de capas, no con la ceremonia de varios paquetes.
