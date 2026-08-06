# Fuentes de FERNÉ

Aprobadas por decisión **D-023**. Ambas con licencia **SIL Open Font License 1.1**, que
permite incrustarlas en una aplicación comercial sin coste ni atribución en pantalla.

| Fuente | Uso | Archivos esperados |
|---|---|---|
| **Libre Caslon Text** | Logotipo, saludos y titulares editoriales | `LibreCaslonText-Regular.ttf`, `LibreCaslonText-Bold.ttf` |
| **Hanken Grotesk** | Textos de marca, subtítulos y contenido general | `HankenGrotesk-Regular.ttf`, `HankenGrotesk-Medium.ttf`, `HankenGrotesk-SemiBold.ttf`, `HankenGrotesk-Bold.ttf` |
| **SF Pro / sistema** | Controles nativos pequeños y accesibilidad | ya incluida en iOS |

## Solo los pesos realmente necesarios

**6 archivos, no 9.** Cada corte añade peso al binario, así que solo se declara lo que
`FerneFont` usa de verdad:

| Archivo | Lo usa |
|---|---|
| `LibreCaslonText-Regular.ttf` | `sectionTitle` |
| `LibreCaslonText-Bold.ttf` | `display`, `greeting`, `scoreNumber` |
| `HankenGrotesk-Regular.ttf` | `body`, `secondary` |
| `HankenGrotesk-Medium.ttf` | `meta` |
| `HankenGrotesk-SemiBold.ttf` | `cardTitle`, `button` |
| `HankenGrotesk-Bold.ttf` | `labelCaps` |

La cursiva de Libre Caslon se descartó: ninguna vista la usa.

**No descargues más de estos seis.** Si en el futuro hace falta un peso nuevo, se añade
entonces, no "por si acaso".

**Procedencia:** únicamente desde Google Fonts o el repositorio oficial de cada familia.
Nada de agregadores de terceros ni paquetes de origen dudoso.

## ESTADO: archivos pendientes de descarga

Los `.ttf` **no están en el repositorio todavía**. No se han descargado desde este entorno
para no introducir binarios sin que puedas verificar su procedencia.

`FerneFont` ya está preparado: si una fuente no está registrada, **cae automáticamente a la
del sistema** con el mismo diseño (serif o sans). La app funciona igual; solo cambia el
carácter tipográfico.

### Cómo añadirlas

1. Descarga desde Google Fonts:
   - https://fonts.google.com/specimen/Libre+Caslon+Text
   - https://fonts.google.com/specimen/Hanken+Grotesk
2. Descomprime y copia **solo los `.ttf` estáticos** en esta carpeta. Si el paquete trae una
   fuente variable (`HankenGrotesk[wght].ttf`), sirve igual, pero registra ese nombre.
3. Copia el `OFL.txt` de cada familia a `Licenses/`, renombrado:
   - `Licenses/LibreCaslonText-OFL.txt`
   - `Licenses/HankenGrotesk-OFL.txt`
4. Ejecuta `bash Scripts/verify-fonts.sh` para comprobar que todo cuadra.
5. Regenera el proyecto: el `Info.plist` ya declara `UIAppFonts` con estos nombres.

## Reglas que no se negocian

- **No modificar los archivos de fuente.** Ni renombrar internamente, ni subsetear, ni
  convertir. La OFL lo permitiría con condiciones, pero no hay motivo y complica la licencia.
- **No usar pesos que no estén incluidos.** iOS los sintetizaría con un falso negrita de
  calidad pobre. Si hace falta un peso, se descarga ese archivo.
- **Las licencias viajan con la app.** `Licenses/` debe estar en el bundle.
- **Verificar caracteres españoles** antes de dar por buena la integración: tildes, `ñ`, `¿`,
  `¡`, y muy especialmente la **É de FERNÉ**, que aparece en el logotipo.
- **Verificar Dynamic Type**: las fuentes custom no escalan solas. `FerneFont` usa
  `relativeTo:` en todos los casos; no lo quites.

## Peso añadido al binario

Pendiente de medir. Se registrará aquí y en `docs/DECISIONS.md` cuando los archivos existan.
Estimación: 150–250 KB para Libre Caslon Text (3 cortes) y 200–350 KB para Hanken Grotesk
(4 cortes). Si supera los 600 KB en total, conviene reducir cortes antes que aceptarlo.
