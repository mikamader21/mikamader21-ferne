---
name: create-animation
description: Crea una animación o microinteracción de FERNÉ respetando el presupuesto de movimiento y Reduce Motion. Úsalo para transiciones, escenas, el check elástico, progreso animado o haptics.
---

# /create-animation

## Cuándo usarlo
Al añadir cualquier cosa que se mueva, vibre o se transforme.

## Entradas
- Qué se anima y por qué (el movimiento sin propósito no se aprueba).
- Tipo: transición de UI, escena cinematográfica o ambiente.

## Procedimiento
1. Elige la duración desde `FerneMotion`. Si necesitas una nueva, **declárala allí**, no en la vista.
2. Verifica el rango: UI 200–450 ms, escena 2–3 s.
3. Añade `@Environment(\.accessibilityReduceMotion)` y la variante sin movimiento.
4. Si es ambiente (sol, nubes, partículas), usa `repeatForever(autoreverses:)` con ciclos largos y densidad baja.
5. Si añades haptic, justifica por qué ese momento lo merece.
6. Comprueba el rendimiento: nada de `blur` pesado dentro de celdas que hacen scroll.

## Validaciones
- [ ] Duración dentro del rango.
- [ ] Reduce Motion contemplado, **conservando la escena**.
- [ ] 60 fps en el dispositivo objetivo.
- [ ] Haptic justificado o ausente.

## Fallos comunes
- `.animation(...)` sin `value:`, que anima cosas inesperadas.
- Animar en `onAppear` ignorando Reduce Motion.
- Confundir "reducir movimiento" con "quitar la escena": está prohibido.

## Definición de terminado
Animación implementada, duración justificada, variante Reduce Motion probada y rendimiento comprobado.
