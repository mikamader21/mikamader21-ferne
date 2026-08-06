# Regla · Sistema de diseño

Aplica a: `FERNE/DesignSystem/**`, `FERNE/Features/**`

## Innegociable

1. **Nunca un fondo plano.** Toda pantalla se construye dentro de `FerneScreen` (que incluye `SkyScene`).
2. **Día:** amanecer/tarde con **sol**, nubes, reflejo y partículas. **Noche:** **luna** con halo, estrellas y cielo ciruela-lavanda.
3. **Nunca negro puro.** El color más oscuro admitido es `deepPlum #3C102F`.
4. Los colores vienen **solo** de `FerneColor`. Ningún hex suelto en una vista.
5. El rojo (`criticalRed`) se reserva a errores técnicos y pagos vencidos. Jamás para juzgar hábitos o score.
6. Tarjetas: radio 20–24 pt, borde sutil, sombra rosada ligera.
7. Componente antes que pantalla: si un elemento aparece dos veces, va a `DesignSystem/Components`.

## Tipografía

- Encabezados: `FerneFont.display / greeting / sectionTitle` (serif del sistema).
- Cuerpo: `FerneFont.body / secondary`.
- Siempre Dynamic Type. Prohibido `.system(size:)` fijo para texto esencial.
- Texto esencial nunca por debajo de 14 pt equivalentes.

## Antes de dar por buena una pantalla

- Capturas en tamaño de texto compacto, estándar y grande.
- Capturas en mañana, tarde y noche.
- Comparación contra la referencia aprobada.
