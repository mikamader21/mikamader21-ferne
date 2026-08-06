# ============================================================
#  FERNÉ · Abrir la galería de diseño desde Windows (PowerShell)
#
#  Uso:
#    .\Scripts\abrir-galeria.ps1
#    .\Scripts\abrir-galeria.ps1 -Capturas "C:\ruta\a\FERNE-screenshots"
#
#  Si Windows bloquea la ejecución del script:
#    powershell -ExecutionPolicy Bypass -File .\Scripts\abrir-galeria.ps1
#
#  Este script no borra nada, no instala nada y no envía datos.
# ============================================================
param(
    [string]$Capturas = ""
)

$ErrorActionPreference = "Stop"
$proyecto = Split-Path -Parent $PSScriptRoot

Write-Host ""
Write-Host "  FERNÉ · Galería de diseño" -ForegroundColor Magenta
Write-Host "  =========================" -ForegroundColor Magenta
Write-Host ""

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
if (-not $python) {
    Write-Host "  [ERROR] No se encontró Python en el PATH." -ForegroundColor Red
    Write-Host "  Instálalo desde https://www.python.org/downloads/ marcando 'Add Python to PATH'."
    exit 1
}

Push-Location $proyecto
try {
    if ([string]::IsNullOrWhiteSpace($Capturas)) {
        Write-Host "  Generando galería solo con las referencias aprobadas..."
        & $python.Source "Scripts\build-gallery.py"
    } else {
        if (-not (Test-Path $Capturas)) {
            Write-Host "  [ERROR] No existe la carpeta de capturas: $Capturas" -ForegroundColor Red
            exit 1
        }
        Write-Host "  Generando galería con las capturas de: $Capturas"
        & $python.Source "Scripts\build-gallery.py" --screenshots $Capturas
    }

    $indice = Join-Path $proyecto "gallery\index.html"
    if (Test-Path $indice) {
        Write-Host ""
        Write-Host "  Abriendo en el navegador..."
        Start-Process $indice
        Write-Host ""
        Write-Host "  Recuerda: esto es una vista previa visual." -ForegroundColor Yellow
        Write-Host "  La validación real se ejecuta en iOS Simulator mediante CI macOS." -ForegroundColor Yellow
    } else {
        Write-Host "  [ERROR] No se generó la galería." -ForegroundColor Red
        exit 1
    }
}
finally {
    Pop-Location
    Write-Host ""
}
