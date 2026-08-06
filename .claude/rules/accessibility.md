# Regla · Accesibilidad

Aplica a: `FERNE/Features/**`, `FERNE/DesignSystem/**`

- **Dynamic Type** en todo texto. Probar en tamaño compacto, estándar y accesibilidad grande.
- **VoiceOver**: cada elemento interactivo con `accessibilityLabel` y, si la acción no es obvia, `accessibilityHint`. Agrupar con `accessibilityElement(children:)` lo que se lee como una unidad (una fila de actividad es un elemento, no cinco).
- **Área táctil mínima 44×44 pt**, aunque el dibujo sea menor (ver `FerneCheckmark`).
- **Nunca solo color**: el estado se acompaña de icono o texto.
- **Reduce Motion**: se detiene el movimiento, pero la escena conserva cielo, astro, halo y nubes. Reducir movimiento no significa fondo plano.
- **Reduce Transparency**: las superficies translúcidas de la noche pasan a sólidas.
- Orden de foco lógico, de arriba abajo.
- Todo sonido va acompañado de texto o señal visual.
