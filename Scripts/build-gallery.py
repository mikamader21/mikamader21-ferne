#!/usr/bin/env python3
"""Galería local de FERNÉ para revisar el diseño desde Windows.

Reúne en una sola página:
  · las referencias aprobadas de docs/design-references/
  · las capturas reales que produjo GitHub Actions (si se han descargado)
  · el estado de cada pantalla según docs/VISUAL_QA_MATRIX.md

Lo que NO hace, por diseño:
  · No reconstruye FERNÉ en HTML, React ni JavaScript.
  · No dibuja nada: solo muestra PNG que ya existen.
  · No sustituye a la validación en iOS Simulator.

Uso:
    python Scripts/build-gallery.py
    python Scripts/build-gallery.py --screenshots ruta\\a\\FERNE-screenshots
"""
from __future__ import annotations

import argparse
import html
import os
import re
import shutil
from datetime import datetime

AVISO = "Vista previa visual. La validación real se ejecuta en iOS Simulator mediante CI macOS."

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REFERENCES_DIR = os.path.join(ROOT, "docs", "design-references")
MATRIX_PATH = os.path.join(ROOT, "docs", "VISUAL_QA_MATRIX.md")
OUTPUT_DIR = os.path.join(ROOT, "gallery")

# Pantallas del catálogo con referencia aprobada. El resto se lee de la matriz.
REFERENCE_MAP = {
    "01": ("Splash cinematográfico", "01-splash-approved.png"),
    "04": ("Inicio / Hoy", "02-home-approved.png"),
    "36": ("Mi progreso", "03-progress-approved.png"),
}

STATE_LABEL = {
    "✅": ("ok", "sí"),
    "🟡": ("partial", "parcial"),
    "⬜": ("todo", "pendiente"),
    "⛔": ("blocked", "bloqueado"),
    "—": ("na", "n/a"),
}


def read_matrix() -> list[dict]:
    """Extrae las filas de la tabla por pantalla de VISUAL_QA_MATRIX.md."""
    if not os.path.isfile(MATRIX_PATH):
        return []
    rows = []
    with open(MATRIX_PATH, encoding="utf-8") as handle:
        for line in handle:
            if not line.startswith("| "):
                continue
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) < 8:
                continue
            match = re.match(r"^(\d{2}(?:,\s*\d{2})*|\d{2}[–-]\d{2}.*)\s*·?\s*(.*)$", cells[0])
            if not match:
                continue
            rows.append({
                "number": match.group(1),
                "name": match.group(2) or cells[0],
                "implemented": cells[1],
                "compiles": cells[2],
                "screenshot": cells[3],
                "compared": cells[4],
                "accessibility": cells[5],
                "approved": cells[6],
                "notes": cells[7] if len(cells) > 7 else "",
            })
    return rows


def badge(symbol: str) -> str:
    cls, text = STATE_LABEL.get(symbol.strip(), ("na", symbol.strip() or "—"))
    return f'<span class="b {cls}">{html.escape(text)}</span>'


def collect(source: str, target: str, prefix: str) -> list[str]:
    """Copia los PNG a la carpeta de la galería y devuelve sus nombres."""
    if not source or not os.path.isdir(source):
        return []
    os.makedirs(target, exist_ok=True)
    names = []
    for entry in sorted(os.listdir(source)):
        if entry.lower().endswith(".png"):
            shutil.copy2(os.path.join(source, entry), os.path.join(target, entry))
            names.append(f"{prefix}/{entry}")
    return names


def build(screenshots_dir: str | None) -> int:
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    references = collect(REFERENCES_DIR, os.path.join(OUTPUT_DIR, "referencias"), "referencias")
    shots = collect(screenshots_dir, os.path.join(OUTPUT_DIR, "capturas"), "capturas") if screenshots_dir else []
    rows = read_matrix()

    ref_by_file = {os.path.basename(r): r for r in references}
    generated = datetime.now().strftime("%d/%m/%Y %H:%M")

    parts = [f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FERNÉ · Galería de diseño</title>
<style>
 :root {{ --ivory:#FFF8F7; --warm:#FFFCFB; --cloud:#FADCE6; --soft:#F7A3BE; --pink:#F45F92;
          --deep:#AE275D; --plum:#3C102F; --plum2:#672846; --gray:#876D79; --gold:#F6C978;
          --green:#9FD4B4; --amber:#F4B86A; }}
 *{{box-sizing:border-box}}
 body{{margin:0;background:var(--ivory);color:var(--plum);
      font:15px/1.55 -apple-system,"Segoe UI",system-ui,sans-serif}}
 header{{padding:32px 28px 18px;background:linear-gradient(150deg,var(--cloud),var(--ivory) 70%)}}
 h1{{margin:0;font:700 30px/1.1 Georgia,"Times New Roman",serif;letter-spacing:4px;color:var(--deep)}}
 .tag{{color:var(--plum2);margin:6px 0 0}}
 .aviso{{margin:18px 28px;padding:13px 16px;border-radius:12px;background:var(--amber);
        color:#3a2408;font-weight:600}}
 .meta{{padding:0 28px 20px;color:var(--gray);font-size:13px}}
 .meta code{{background:var(--warm);padding:2px 6px;border-radius:5px}}
 section{{padding:0 28px 34px}}
 h2{{font-size:19px;margin:26px 0 14px;padding-bottom:8px;border-bottom:1px solid var(--cloud)}}
 .grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:20px}}
 figure{{margin:0;background:var(--warm);border:1px solid rgba(247,163,190,.4);border-radius:16px;
        overflow:hidden;box-shadow:0 6px 20px rgba(244,95,146,.13)}}
 figure img{{width:100%;display:block;background:var(--cloud)}}
 figcaption{{padding:11px 13px;font-size:13px}}
 .t{{font-weight:600;display:block;margin-bottom:5px}}
 .b{{display:inline-block;padding:2px 8px;border-radius:999px;font-size:11px;font-weight:700;margin:2px 3px 0 0}}
 .ok{{background:var(--green);color:#12331f}} .partial{{background:var(--gold);color:#4a3208}}
 .todo{{background:var(--cloud);color:var(--plum2)}} .blocked{{background:var(--plum);color:var(--cloud)}}
 .na{{background:#eee;color:#666}}
 table{{width:100%;border-collapse:collapse;font-size:13px;background:var(--warm);
       border-radius:14px;overflow:hidden}}
 th,td{{padding:9px 11px;text-align:left;border-bottom:1px solid var(--cloud)}}
 th{{background:var(--cloud);font-size:11px;letter-spacing:.06em;text-transform:uppercase}}
 tr:last-child td{{border-bottom:none}}
 .empty{{padding:26px;background:var(--warm);border-radius:14px;color:var(--gray);
        border:1px dashed var(--soft)}}
 footer{{padding:26px 28px;border-top:1px solid var(--cloud);color:var(--gray);font-size:13px}}
 a{{color:var(--deep)}}
</style></head><body>
<header><h1>FERNÉ</h1><p class="tag">Tu día, a tu ritmo. · Galería de diseño</p></header>
<div class="aviso">{html.escape(AVISO)}</div>
<p class="meta">Generada el <code>{generated}</code> ·
 <strong>{len(references)}</strong> referencias aprobadas ·
 <strong>{len(shots)}</strong> capturas de CI ·
 <strong>{len(rows)}</strong> filas en la matriz de QA.</p>
"""]

    # --- Referencias aprobadas ---
    parts.append('<section><h2>Referencias aprobadas</h2>')
    if references:
        parts.append('<div class="grid">')
        for number, (name, filename) in sorted(REFERENCE_MAP.items()):
            path = ref_by_file.get(filename)
            if not path:
                continue
            row = next((r for r in rows if r["number"] == number), None)
            badges = ""
            if row:
                badges = ("Implementada " + badge(row["implemented"]) +
                          " Compila " + badge(row["compiles"]) +
                          " Captura " + badge(row["screenshot"]) +
                          " Comparada " + badge(row["compared"]) +
                          " Aprobada " + badge(row["approved"]))
            parts.append(
                f'<figure><img src="{html.escape(path)}" alt="{html.escape(name)}" loading="lazy">'
                f'<figcaption><span class="t">{number} · {html.escape(name)}</span>{badges}</figcaption></figure>')
        parts.append('</div>')
    else:
        parts.append('<div class="empty">No hay referencias en <code>docs\\design-references\\</code>.</div>')

    OFFICIAL = ("01-splash-approved.png", "02-home-approved.png", "03-progress-approved.png")
    missing = [f for f in OFFICIAL if not os.path.isfile(os.path.join(REFERENCES_DIR, f))]
    if missing:
        parts.append('<div class="empty" style="margin-top:16px">'
                     '<strong>Falta una referencia oficial:</strong><br>' +
                     "<br>".join(f"<code>{html.escape(m)}</code>" for m in missing) +
                     '<br><br>No se ha creado ningún sustituto.</div>')
    else:
        parts.append('<div class="empty" style="margin-top:16px;border-style:solid;'
                     'border-color:#9FD4B4">Conjunto visual <strong>completo</strong>: '
                     'las tres referencias oficiales están presentes y verificadas.<br><br>'
                     'Son la autoridad visual de <strong>las 40 pantallas</strong>, no solo de '
                     'las tres que retratan. Ver <code>docs\\DESIGN_REFERENCES.md</code>.</div>')
    parts.append('</section>')

    # --- Capturas de CI ---
    parts.append('<section><h2>Capturas del simulador (CI macOS)</h2>')
    if shots:
        parts.append('<div class="grid">')
        for path in shots:
            stem = os.path.basename(path)[:-4]
            device, _, scenario = stem.partition("__")
            parts.append(
                f'<figure><img src="{html.escape(path)}" alt="{html.escape(stem)}" loading="lazy">'
                f'<figcaption><span class="t">{html.escape(scenario or stem)}</span>'
                f'<span class="b na">{html.escape(device)}</span></figcaption></figure>')
        parts.append('</div>')
    else:
        parts.append('<div class="empty">Todavía no hay capturas.<br><br>'
                     'Se generan al ejecutar el workflow <code>iOS CI</code> en GitHub Actions. '
                     'Descarga el artifact <code>FERNE-screenshots</code>, descomprímelo y vuelve a '
                     'generar la galería:<br><br>'
                     '<code>python Scripts\\build-gallery.py --screenshots C:\\ruta\\FERNE-screenshots</code>'
                     '</div>')
    parts.append('</section>')

    # --- Matriz ---
    parts.append('<section><h2>Estado por pantalla</h2>')
    if rows:
        parts.append('<table><tr><th>#</th><th>Pantalla</th><th>Implem.</th><th>Compila</th>'
                     '<th>Captura</th><th>Comparada</th><th>Accesib.</th><th>Aprobada</th>'
                     '<th>Observaciones</th></tr>')
        for row in rows:
            parts.append(
                f'<tr><td>{html.escape(row["number"])}</td><td>{html.escape(row["name"])}</td>'
                f'<td>{badge(row["implemented"])}</td><td>{badge(row["compiles"])}</td>'
                f'<td>{badge(row["screenshot"])}</td><td>{badge(row["compared"])}</td>'
                f'<td>{badge(row["accessibility"])}</td><td>{badge(row["approved"])}</td>'
                f'<td>{html.escape(row["notes"])}</td></tr>')
        parts.append('</table>')
    else:
        parts.append('<div class="empty">No se pudo leer <code>docs\\VISUAL_QA_MATRIX.md</code>.</div>')
    parts.append('</section>')

    parts.append(f"""<footer>
<p><strong>Qué es esto.</strong> Un índice estático de imágenes que ya existen: tus referencias
aprobadas y las capturas que genera el runner macOS. Sirve para revisar el diseño desde Windows.</p>
<p><strong>Qué no es.</strong> No es la aplicación. No prueba navegación, notificaciones, sonidos,
haptics ni rendimiento. Ninguna pantalla puede darse por terminada solo con esta galería.</p>
<p>Para interactuar con FERNÉ desde el navegador: <code>docs\\WINDOWS_IOS_PREVIEW.md</code>.<br>
Para las pruebas que exigen un iPhone físico: <code>docs\\NOTIFICATIONS_TEST_MATRIX.md</code>.</p>
</footer></body></html>""")

    output = os.path.join(OUTPUT_DIR, "index.html")
    with open(output, "w", encoding="utf-8") as handle:
        handle.write("\n".join(parts))

    print(f"Galería generada: {output}")
    print(f"  Referencias : {len(references)}")
    print(f"  Capturas    : {len(shots)}")
    print(f"  Pantallas   : {len(rows)}")
    if missing:
        print(f"  FALTA       : {', '.join(missing)}")
    else:
        print("  Conjunto visual completo (3/3 referencias oficiales).")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Genera la galería local de FERNÉ.")
    parser.add_argument("--screenshots", help="Carpeta con las capturas descargadas de GitHub Actions.")
    args = parser.parse_args()
    raise SystemExit(build(args.screenshots))
