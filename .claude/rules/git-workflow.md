# Regla · Flujo de trabajo

Aplica a: todo el repositorio

1. **Nunca hacer commit, push, tag ni publicar sin autorización explícita de Mika.**
2. Una fase = una rama (`fase/1-nucleo-funcional`). Nada de trabajo directo sobre `main`.
3. Antes de proponer un commit: `make gate` debe pasar (o reportar honestamente qué quedó sin verificar y por qué).
4. Nunca ejecutar comandos destructivos: `rm -rf` fuera de `build/`, `git reset --hard`, `git push --force`, `git clean -fdx`.
5. Nunca borrar trabajo existente sin haberlo inspeccionado y sin avisar.
6. Después de cada fase, actualizar `docs/CHECKLIST.md` y `docs/DECISIONS.md` con: decisiones tomadas, archivos modificados, pruebas ejecutadas y resultado real.
7. Los errores, warnings y limitaciones se reportan. Nunca se ocultan ni se silencian con `// swiftlint:disable` sin justificación escrita.
