---
name: audit-accessibility
description: Audita la accesibilidad de una pantalla de FERNÉ. Úsalo antes de dar por terminada cualquier vista y como parte del cierre de fase.
---

# /audit-accessibility

## Cuándo usarlo
Tras implementar o modificar una vista, y antes de aceptarla.

## Entradas
Ruta del archivo de la vista o nombre de la pantalla.

## Procedimiento
1. Recorre cada elemento interactivo y comprueba `accessibilityLabel` y, si hace falta, `accessibilityHint`.
2. Comprueba la agrupación: lo que se lee como una unidad debe ser un solo elemento para VoiceOver.
3. Busca `.system(size:` sin `relativeTo:` en texto: rompe Dynamic Type.
4. Comprueba que ningún control dibujado pequeño tenga área táctil menor de 44×44.
5. Comprueba que ningún estado se comunique **solo** con color.
6. Comprueba Reduce Motion y Reduce Transparency.
7. Comprueba el contraste del texto sobre la escena, especialmente en noche.
8. Verifica el orden de foco.

## Validaciones
- [ ] VoiceOver recorre la pantalla con sentido.
- [ ] Dynamic Type en compacto, estándar y accesibilidad grande sin recortes.
- [ ] Áreas táctiles ≥ 44 pt.
- [ ] Color nunca es el único canal de información.
- [ ] Reduce Motion conserva la escena.

## Fallos comunes
- Un `HStack` que VoiceOver lee como cinco elementos inconexos.
- Icono decorativo sin `accessibilityHidden(true)`.
- Texto `.footnote` usado para información esencial.
- Texto claro sobre el degradado nocturno con contraste insuficiente.

## Definición de terminado
Lista de incumplimientos con archivo y línea, correcciones aplicadas, y declaración explícita de lo que no pudo verificarse sin dispositivo real.
