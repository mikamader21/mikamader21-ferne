# Historial de ejecuciones del pipeline

Registro de cada ejecución de `iOS CI`, con lo aprendido. Los logs crudos no se versionan
(son artefactos); aquí queda el diagnóstico.

---

## Run 1 · 6 de agosto de 2026 · ❌ FALLÓ

| | |
|---|---|
| Run ID | `31113620877` |
| Job iOS | `92657788201` |
| Runner | `macos-15` · imagen `20260707.563` · runner `2.336` |
| Xcode | **16.4** (build 16F6) |
| Swift | **6.1.2** (swiftlang-6.1.2.1.2, clang-1700.0.13.5) |
| XcodeGen | 2.46.0 |
| SwiftFormat | **0.62.1** |
| SwiftLint | 0.65.0 (instalado, no llegó a ejecutarse) |
| Commit | `acc334c` — *FERNE: phases 0 and 0.5 foundation* |

### Qué llegó a ejecutarse

| Paso | Resultado |
|---|---|
| Preflight (Linux) | ✅ |
| Checkout · Xcode · XcodeGen | ✅ |
| Generar `FERNE.xcodeproj` | ✅ |
| Validar el proyecto generado | ✅ |
| **SwiftFormat `--lint`** | ❌ **primer fallo** |
| SwiftLint · simulador · compilación · tests | ⬜ no alcanzados |
| Artifact `FERNE.app` | ❌ efecto colateral, no causa |
| Capturas | ⬜ no generadas |

### Causa raíz

```
SwiftFormat completed in 1s.
35/46 files require formatting, 33 files skipped.
##[error]Process completed with exit code 1.
```

**326 incumplimientos** en 35 de 46 archivos.

Por regla:

| Regla | Nº | Naturaleza |
|---|---:|---|
| `consecutiveSpaces` | 94 | formato |
| `wrap` | 71 | formato |
| `wrapPropertyBodies` | 43 | formato |
| `indent` | 34 | formato |
| `trailingCommas` | 19 | formato |
| `spaceAroundOperators` | 15 | formato |
| **`environmentEntry`** | 10 | **reescritura de API** |
| `docComments` | 9 | formato |
| `wrapIfStatementBodies` | 7 | formato |
| `blankLinesBetweenScopes` | 6 | formato |
| **`noForceUnwrapInTests`** | 5 | **cambio de semántica** |
| **`hoistTry`** | 3 | **cambio estructural** |
| `wrapFunctionBodies` | 2 | formato |
| `redundantSelf` | 2 | formato |
| `blankLinesAtStartOfScope` | 2 | formato |
| **`redundantType`** | 1 | **cambio de contenido** |
| `redundantParens` | 1 | formato (verificado) |
| **`preferKeyPath`** | 1 | **reescritura de código** |
| `blankLinesAroundMark` | 1 | formato |

### Diagnóstico

El fallo real no era el formato en sí, sino que **`.swiftformat` no declaraba qué reglas
aplicar**. SwiftFormat ejecutaba su conjunto por defecto, que incluye cinco reglas que **no
reformatean: reescriben código**. `environmentEntry`, por ejemplo, habría convertido el
`EnvironmentKey` manual de `FerneTheme` en la macro `@Entry` — un cambio de API que nadie
había decidido.

Aplicar `swiftformat` sin más habría metido esos cambios de tapadillo dentro de un commit
etiquetado como "formato".

### Correcciones

1. **Versiones fijadas.** SwiftFormat 0.62.1 y SwiftLint 0.65.0 se descargan de sus releases
   oficiales en lugar de `brew install` (que instala la última del día). Un paso comprueba
   que la versión instalada coincide con la fijada y que `.swiftformat` la declara en su
   cabecera.
2. **Cinco reglas desactivadas**, cada una con su motivo escrito en `.swiftformat`:
   `environmentEntry`, `noForceUnwrapInTests`, `preferKeyPath`, `hoistTry`, `redundantType`.
3. **Código formateado con la misma versión 0.62.1**, verificando que el diff funcional es cero.
4. **El artifact de la app deja de generar un segundo error.** Cuando no hay compilación,
   escribe `NO-SE-GENERO.txt` explicando que es una consecuencia y no la causa, emite un
   `::warning` y no rompe el paso. El fallo original conserva el protagonismo.
5. **Actions actualizadas a Node 24:** `checkout@v7`, `upload-artifact@v7`,
   `download-artifact@v8`. Verificadas: organización `actions`, etiquetas existentes,
   `using: node24`.

### Nota sobre el aviso de Node.js 20

Era una advertencia de obsolescencia, **no la causa del fallo**. Se ha resuelto igualmente
al subir de versión las actions.
