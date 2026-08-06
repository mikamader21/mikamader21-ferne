# FERNÉ — Instrucciones permanentes

> **Fuente de verdad: [`docs/MASTER_SPEC.md`](docs/MASTER_SPEC.md)** — copia de trabajo.
> [`docs/FERNE_MASTER_SPEC.md`](docs/FERNE_MASTER_SPEC.md) es el original v1.0 congelado, byte a byte como se entregó. Los dos son idénticos hoy; si alguna vez divergen, gana el original.
> Ante cualquier duda o contradicción, gana la especificación. Si algo la contradice: **detente, documenta el conflicto en `docs/DECISIONS.md` y pide aprobación.** No improvises.

## Ubicación oficial

```
C:\Users\MIKA\Documents\Claude\Projects\FERNE
```

Este es el **único** directorio de trabajo del proyecto. Cualquier copia en carpetas
temporales de sesión es un respaldo congelado, no la fuente de verdad.

## Entorno de desarrollo

**Desarrollo principal desde Windows, compilación iOS remota y preview desde navegador.**
No hay Mac ni iPhone disponibles. Consecuencias que no se negocian:

| Dónde | Qué se verifica |
|---|---|
| Windows (local) | Lógica de dominio, guards de diseño, documentación, preparación |
| GitHub Actions macOS | Compilación iOS, tests unitarios, UI tests, cobertura, capturas |
| Appetize.io (navegador) | Navegación y animaciones sobre un simulador remoto |
| iPhone real (pendiente) | Notificaciones, AlarmKit, sonidos, haptics, pantalla bloqueada |

Nada que requiera un iPhone físico puede marcarse como aprobado hasta ejecutarse en uno.
Ver `docs/BUILD.md` y `docs/WINDOWS_IOS_PREVIEW.md`.

## Referencias visuales

`docs/design-references/` contiene el **conjunto completo**: tres imágenes oficiales más
`DESIGN-TOKENS.md`. **No existe ni se espera una cuarta.**

| Referencia | Define, para TODA la app |
|---|---|
| `01-splash-approved.png` | Identidad cinematográfica, gradientes, luz, partículas, profundidad, movimiento |
| `02-home-approved.png` | Organización visual, tarjetas, jerarquía, saludo, escena, agenda, iconografía |
| `03-progress-approved.png` | Indicadores, gráficas, círculos, score, estados, recomendaciones |

**Son la autoridad visual de las 40 pantallas**, no solo de las tres que retratan. Las otras
37 se derivan de ellas: misma identidad, colores, tipografía, radios, tarjetas, profundidad,
iconografía, iluminación, lenguaje visual y la misma sensación alegre, viva y cinematográfica.

No hace falta una imagen aprobada por pantalla antes de implementarla. `visual-guardian`
evalúa cada pantalla nueva contra el sistema derivado.

**La referencia manda sobre §4.2** cuando exista una diferencia demostrable.

Decisiones tomadas: colores atmosféricos aprobados (D-022), tipografía Libre Caslon +
Hanken Grotesk (D-023), escena nocturna derivada (D-024).
Diferencias pendientes: [`docs/VISUAL_BACKLOG.md`](docs/VISUAL_BACKLOG.md).

## Qué es

Asistente personal diaria para una sola usuaria (Fer). Nativa, privada, **offline-first**.
Promesa: *"Tu día, a tu ritmo."*

## Stack

- iOS **18.0+**, iPhone, solo vertical. Swift **6** con concurrencia estricta.
- SwiftUI · SwiftData · UserNotifications · AlarmKit (con fallback) · Swift Charts · CloudKit privado (opcional) · Keychain.
- Proyecto generado con **XcodeGen** desde `project.yml`. No editar `FERNE.xcodeproj` a mano.

## Arquitectura

```
Domain/       Foundation puro. Entidades, score, casos de uso. NUNCA importa SwiftUI/SwiftData/UIKit.
Data/         SwiftData, CloudKit, repositorios, migraciones versionadas.
Services/     Notificaciones, alarmas, audio, haptics, fecha/hora, IA opcional.
DesignSystem/ Tokens, temas mañana/tarde/noche, escenas, componentes.
Features/     Vistas y view models por feature.
```

Las reglas de negocio **no** viven en las vistas. Detalle en [`.claude/rules/architecture.md`](.claude/rules/architecture.md).

## Comandos

**Desde Windows (lo que puedes ejecutar ahora):**

```bash
bash Scripts/verify-logic.sh           # 40 pruebas de Domain/Score, sin Xcode
bash Scripts/design-guard.sh           # paleta, capas, lenguaje, secretos, fondos planos
bash Scripts/verify-spec-integrity.sh  # los dos documentos maestros no han divergido
bash Scripts/inventory.sh              # inventario oficial (cifra única y oficial)
bash Scripts/verify-fonts.sh           # fuentes personalizadas y sus licencias
bash Scripts/quality-gate.sh           # los 9 pasos, con reporte honesto de lo omitido
```

```bat
Scripts\abrir-galeria.bat              REM galería de diseño en el navegador
```

**En GitHub Actions (fuente de verdad del build):** `.github/workflows/ios-ci.yml`.
Compila, prueba, mide cobertura, captura y empaqueta `FERNE.app`.
Estado: **configurado y validado estáticamente; ejecución remota pendiente.**

**Si algún día hay un Mac:** `make generate`, `make build`, `make test`, `make gate`.

## Reglas innegociables

1. **No añadir dependencias sin justificarlas y pedir aprobación.** Preferir frameworks de Apple. Prohibidos: Supabase, Firebase, analytics, React/React Native/Expo/Flutter, cualquier librería de UI genérica.
2. **Nada está terminado sin compilar, probar y verificar visualmente.** No declarar "listo" lo que no se ejecutó.
3. **Preservar la identidad visual aprobada.** Nunca un fondo plano: sol de día, luna de noche, cielo ciruela por la noche, jamás negro puro. Todos los colores desde `FerneColor`.
4. **Cero secretos en el repositorio.** Claves de IA solo en Keychain. Nunca registrar datos personales en logs.
5. **Offline-first.** Ninguna función central puede depender de internet ni de iCloud.
6. **La IA es opcional** y jamás bloquea nada.
7. **No ocultar errores, warnings, pruebas fallidas ni limitaciones.** Se reportan.
8. **Sin comandos destructivos.** No borrar trabajo existente sin inspeccionarlo. Sin commits, push ni publicaciones sin autorización explícita.
9. **Mantener actualizados** `docs/CHECKLIST.md` y `docs/DECISIONS.md` tras cada fase: decisiones, archivos modificados, pruebas ejecutadas y resultados reales.
10. **Una fase a la vez.** No crear las 40 pantallas como cascarones vacíos.
11. **No inventar aprobaciones.** El build solo está verificado si hay una ejecución de
    `iOS CI` en verde. Lo revisado en Appetize es 🟡, nunca ✅. Las notificaciones, sonidos
    y haptics son **NO VERIFICADO** hasta que exista un iPhone
    (`docs/NOTIFICATIONS_TEST_MATRIX.md`).
12. **No reconstruir FERNÉ en HTML, React ni JavaScript**, ni siquiera "para verla rápido".
    La galería solo muestra PNG que ya existen.
13. **No crear repositorios, subir nada ni conectar servicios externos** sin tu autorización.

## Lenguaje

Textos visibles en español. FERNÉ orienta, nunca castiga: prohibido "fracaso", "mala", "insuficiente", "perezosa" y equivalentes (`Domain/Score/ScoreLanguage.swift` lo verifica con pruebas).

## Reglas por área

[`architecture`](.claude/rules/architecture.md) · [`design-system`](.claude/rules/design-system.md) · [`swift-style`](.claude/rules/swift-style.md) · [`notifications`](.claude/rules/notifications.md) · [`persistence`](.claude/rules/persistence.md) · [`privacy-security`](.claude/rules/privacy-security.md) · [`testing`](.claude/rules/testing.md) · [`accessibility`](.claude/rules/accessibility.md) · [`git-workflow`](.claude/rules/git-workflow.md)

## Documentos clave

| Documento | Para qué |
|---|---|
| [`docs/CHECKLIST.md`](docs/CHECKLIST.md) | Estado vivo del proyecto |
| [`docs/PHASE_PLAN.md`](docs/PHASE_PLAN.md) | Las 9 fases y sus criterios |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Por qué se hizo cada cosa. 21 decisiones registradas |
| [`docs/DESIGN_REFERENCES.md`](docs/DESIGN_REFERENCES.md) | Análisis de las tres referencias |
| [`docs/VISUAL_BACKLOG.md`](docs/VISUAL_BACKLOG.md) | 25 diferencias priorizadas P0–P3 |
| [`docs/VISUAL_QA_MATRIX.md`](docs/VISUAL_QA_MATRIX.md) | Estado visual pantalla por pantalla |
| [`docs/BUILD.md`](docs/BUILD.md) | Los cuatro caminos de verificación |
| [`docs/WINDOWS_IOS_PREVIEW.md`](docs/WINDOWS_IOS_PREVIEW.md) | Ver la app desde Windows |
| [`docs/NOTIFICATIONS_TEST_MATRIX.md`](docs/NOTIFICATIONS_TEST_MATRIX.md) | Qué se puede aprobar y dónde |
