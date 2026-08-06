---
name: build-screen
description: Construye una de las 40 pantallas del catálogo de FERNÉ, de principio a fin y verificada. Úsalo cuando se pida crear, implementar o terminar una pantalla concreta (por número o por nombre).
---

# /build-screen

## Cuándo usarlo
Cuando haya que implementar una pantalla del catálogo de `docs/SCREEN_CATALOG.md`. **No** para retoques menores de una pantalla ya aceptada.

## Entradas
- Número y nombre de la pantalla (ej. `04 · Inicio / Hoy`).
- Referencia visual aprobada, si existe.
- Fase en curso (una pantalla no se construye antes de que su fase tenga el núcleo listo).

## Procedimiento
1. Lee la sección de esa pantalla en `docs/MASTER_SPEC.md` §6 y en `docs/SCREEN_CATALOG.md`. **No resumas: cíñete al texto.**
2. Comprueba qué componentes de `DesignSystem/Components` ya existen. Si falta uno reutilizable, créalo **antes** que la pantalla.
3. Implementa la vista dentro de `FerneScreen`. Nunca un fondo plano.
4. Cubre los cinco estados: normal, vacío, cargando, error y accesibilidad.
5. Usa datos de `PreviewContent/PreviewData.swift` mientras no exista la capa de datos real.
6. Añade `#Preview` de **mañana** y de **noche** como mínimo.
7. Etiqueta para VoiceOver y agrupa lo que se lee como unidad.
8. Escribe las pruebas correspondientes.
9. Ejecuta `bash Scripts/design-guard.sh` y `make test`.
10. Pasa el resultado por el agente `visual-guardian` y por `accessibility-reviewer`.

## Validaciones
- [ ] Compila sin warnings nuevos.
- [ ] Escena día y noche correctas.
- [ ] Cinco estados implementados.
- [ ] Área táctil ≥ 44 pt en todo control.
- [ ] Copy literal de la especificación, sin inventar.
- [ ] Tests en verde.

## Fallos comunes
- Empezar por la pantalla en lugar de por el componente reutilizable.
- Usar un `Color` suelto en vez de `FerneColor`.
- Olvidar el estado vacío (que en FERNÉ nunca es una pantalla en blanco).
- Poner lógica de negocio dentro de la vista.

## Definición de terminado
Compilada, probada, verificada visualmente en día y noche, accesible y con la documentación y el checklist actualizados. Sin esos cinco, **no está terminada**.
