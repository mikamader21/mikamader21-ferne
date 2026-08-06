# FERNÉ

> **Tu día, a tu ritmo.**

Asistente personal diaria, nativa, privada y **offline-first** para iPhone.

- **Plataforma:** iOS 18+ · iPhone · orientación vertical
- **Stack:** SwiftUI · SwiftData · UserNotifications · AlarmKit (con fallback) · Swift Charts · CloudKit privado (opcional)
- **Fuente de verdad:** [`docs/MASTER_SPEC.md`](docs/MASTER_SPEC.md)

## Estado

| Fase | Descripción | Estado |
|---|---|---|
| 0 | Preparación: repo, Brain, design system, esqueleto | **En verificación** (bloqueo: sin macOS/Xcode en el entorno actual) |
| 1 | Núcleo funcional (modelos, SwiftData, CRUD actividades) | Pendiente |
| 2 | Inicio y agenda | Pendiente |
| 3 | Categorías | Pendiente |
| 4 | Notificaciones | Pendiente |
| 5 | Progreso y score | Pendiente |
| 6 | Personal y ajustes | Pendiente |
| 7 | Cinemática y polish | Pendiente |
| 8 | QA y distribución | Pendiente |

Checklist vivo: [`docs/CHECKLIST.md`](docs/CHECKLIST.md)

## Ubicación oficial

```
C:\Users\MIKA\Documents\Claude\Projects\FERNE
```

## Entorno

Desarrollo desde **Windows**. No hay Mac ni iPhone locales:

- **Windows** → lógica, guards, documentación (`bash Scripts/verify-logic.sh`, `bash Scripts/design-guard.sh`)
- **GitHub Actions (runner macOS)** → compilación iOS, tests y capturas reales
- **Appetize.io** → simulador de iPhone en el navegador
- **iPhone real** → pendiente, obligatorio para notificaciones y sonidos

## Requisitos (solo para el runner macOS)

- macOS 15 o superior
- Xcode 16 o superior (Swift 6)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — genera `FERNE.xcodeproj` desde `project.yml`
- (Opcional) SwiftLint y SwiftFormat

```bash
brew install xcodegen swiftlint swiftformat
```

## Generar y compilar

```bash
make generate     # XcodeGen → FERNE.xcodeproj
make build        # xcodebuild sobre simulador iPhone 16 Pro
make test         # pruebas unitarias
make lint         # SwiftLint
make format       # SwiftFormat
make gate         # quality gate completo
```

Ver comandos exactos y alternativa sin XcodeGen en [`docs/BUILD.md`](docs/BUILD.md).

## Principios innegociables

1. Offline-first: ninguna función central requiere internet.
2. Sin backend en el MVP (nada de Supabase/Firebase).
3. Sin secretos en el repositorio.
4. La IA es **opcional** y jamás bloquea una función.
5. Nunca fondo plano genérico: sol de día, luna de noche, profundidad siempre.
6. Ninguna pantalla se declara terminada sin compilar, probar y verificar visualmente.
