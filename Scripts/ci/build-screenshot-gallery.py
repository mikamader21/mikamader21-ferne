#!/usr/bin/env python3
"""Genera un catálogo HTML navegable a partir de las capturas reales de CI.

Por qué existe: desde Windows no hay simulador de iOS. Estas capturas, producidas
por el runner macOS, son la única forma de ver FERNÉ sin abrir Appetize.

Lo que NO es: una prueba funcional, ni una reimplementación de la app. La galería
solo muestra PNG generados por los UI tests. Si un PNG no existe, no se inventa.

Uso: python3 Scripts/ci/build-screenshot-gallery.py <dir-capturas> <salida.html>
"""
from __future__ import annotations

import html
import os
import sys
from collections import defaultdict
from datetime import datetime, timezone

AVISO = "Vista previa visual — la validación real se ejecuta en iOS Simulator."


def parse(filename: str) -> tuple[str, str, str]:
    """`iphone-16-pro__home-noche.png` → (dispositivo, escenario, franja)."""
    stem = filename[:-4] if filename.lower().endswith(".png") else filename
    device, _, scenario = stem.partition("__")
    if not scenario:
        device, scenario = "sin-clasificar", stem
    phase = "otro"
    for candidate in ("manana", "tarde", "noche"):
        if scenario.endswith(candidate) or f"-{candidate}-" in scenario:
            phase = candidate
            break
    return device, scenario, phase


def build(source_dir: str, output_path: str) -> int:
    if not os.path.isdir(source_dir):
        print(f"AVISO: no existe el directorio de capturas '{source_dir}'.")
        images = []
    else:
        images = sorted(f for f in os.listdir(source_dir) if f.lower().endswith(".png"))

    grouped: dict[str, list[tuple[str, str, str]]] = defaultdict(list)
    for name in images:
        device, scenario, phase = parse(name)
        grouped[device].append((name, scenario, phase))

    generated = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    commit = os.environ.get("GITHUB_SHA", "local")[:8]
    run = os.environ.get("GITHUB_RUN_NUMBER", "local")

    parts: list[str] = []
    parts.append(f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FERNÉ · Galería de capturas</title>
<style>
  :root {{
    --ivory: #FFF8F7; --warm: #FFFCFB; --cloud: #FADCE6; --soft: #F7A3BE;
    --pink: #F45F92; --plum: #3C102F; --plum2: #672846; --gray: #876D79;
    --amber: #F4B86A;
  }}
  * {{ box-sizing: border-box; }}
  body {{ margin: 0; background: var(--ivory); color: var(--plum);
         font: 15px/1.5 -apple-system, "Segoe UI", system-ui, sans-serif; }}
  header {{ padding: 28px 24px 20px; background: linear-gradient(160deg, var(--cloud), var(--ivory)); }}
  h1 {{ margin: 0 0 4px; font-size: 26px; font-family: Georgia, "Times New Roman", serif; letter-spacing: 3px; }}
  .tagline {{ color: var(--plum2); margin: 0 0 16px; }}
  .warning {{ background: var(--amber); color: #3a2408; padding: 12px 16px;
              border-radius: 12px; font-weight: 600; margin: 0 24px 20px; }}
  .meta {{ color: var(--gray); font-size: 13px; padding: 0 24px 18px; }}
  .meta code {{ background: var(--warm); padding: 2px 6px; border-radius: 5px; }}
  section {{ padding: 0 24px 32px; }}
  h2 {{ font-size: 18px; border-bottom: 1px solid var(--cloud); padding-bottom: 8px; }}
  .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 18px; }}
  figure {{ margin: 0; background: var(--warm); border: 1px solid rgba(247,163,190,.35);
            border-radius: 16px; overflow: hidden; box-shadow: 0 6px 18px rgba(244,95,146,.12); }}
  figure img {{ width: 100%; display: block; background: var(--cloud); }}
  figcaption {{ padding: 10px 12px; font-size: 13px; }}
  .scenario {{ font-weight: 600; display: block; }}
  .badge {{ display: inline-block; margin-top: 6px; padding: 2px 8px; border-radius: 999px;
            font-size: 11px; font-weight: 700; }}
  .manana {{ background: #F6C978; color: #4a3208; }}
  .tarde  {{ background: #F7A39A; color: #4a1810; }}
  .noche  {{ background: var(--plum); color: var(--cloud); }}
  .otro   {{ background: var(--cloud); color: var(--plum2); }}
  .empty {{ padding: 40px 24px; color: var(--gray); }}
  footer {{ padding: 24px; color: var(--gray); font-size: 13px; border-top: 1px solid var(--cloud); }}
</style>
</head>
<body>
<header>
  <h1>FERNÉ</h1>
  <p class="tagline">Tu día, a tu ritmo.</p>
</header>
<div class="warning">{html.escape(AVISO)}</div>
<p class="meta">
  Generada el <code>{generated}</code> · commit <code>{commit}</code> · ejecución <code>{run}</code> ·
  <strong>{len(images)}</strong> capturas.
  Estas imágenes proceden de UI tests ejecutados en un simulador de iOS real.
  Ninguna ha sido dibujada ni recreada en HTML.
</p>
""")

    if not images:
        parts.append("""<div class="empty">
  <p>No hay capturas todavía.</p>
  <p>Se generan al ejecutar el workflow <code>iOS CI</code> en GitHub Actions.
     Descarga el artifact <code>FERNE-screenshots</code> y abre este archivo.</p>
</div>""")
    else:
        for device in sorted(grouped):
            parts.append(f'<section><h2>{html.escape(device)}</h2><div class="grid">')
            for name, scenario, phase in sorted(grouped[device], key=lambda x: x[1]):
                parts.append(
                    f'<figure><img src="{html.escape(name)}" alt="{html.escape(scenario)}" loading="lazy">'
                    f'<figcaption><span class="scenario">{html.escape(scenario)}</span>'
                    f'<span class="badge {phase}">{phase}</span></figcaption></figure>'
                )
            parts.append("</div></section>")

    parts.append(f"""<footer>
  <p><strong>Qué es esto:</strong> un índice de capturas reales para revisar el diseño desde Windows.</p>
  <p><strong>Qué NO es:</strong> la aplicación. No prueba navegación, notificaciones, sonidos ni haptics.
     Para interactuar con FERNÉ desde el navegador, usa Appetize (ver <code>docs/WINDOWS_IOS_PREVIEW.md</code>).
     Para dar una pantalla por terminada hace falta, además, comparación con
     <code>docs/design-references/</code> y verificación en iPhone real.</p>
</footer>
</body>
</html>""")

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(parts))

    print(f"Galería generada: {output_path} ({len(images)} capturas, {len(grouped)} dispositivos)")
    return 0


if __name__ == "__main__":
    source = sys.argv[1] if len(sys.argv) > 1 else "artifacts/screenshots"
    output = sys.argv[2] if len(sys.argv) > 2 else "artifacts/screenshots/index.html"
    sys.exit(build(source, output))
