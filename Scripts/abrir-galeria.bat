@echo off
REM ============================================================
REM  FERNE - Abrir la galeria de diseno desde Windows
REM
REM  Regenera la galeria con las referencias aprobadas y las
REM  capturas descargadas de GitHub Actions, y la abre en el
REM  navegador por defecto.
REM
REM  Uso:
REM    Scripts\abrir-galeria.bat
REM    Scripts\abrir-galeria.bat "C:\ruta\a\FERNE-screenshots"
REM
REM  Este script NO borra nada, NO instala nada y NO envia datos.
REM ============================================================
setlocal

set "PROYECTO=%~dp0.."
pushd "%PROYECTO%"

echo.
echo   FERNE - Galeria de diseno
echo   =========================
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] No se encontro Python en el PATH.
    echo.
    echo   Instalalo desde https://www.python.org/downloads/
    echo   y marca la casilla "Add Python to PATH" durante la instalacion.
    echo.
    popd
    pause
    exit /b 1
)

if "%~1"=="" (
    echo   Generando galeria solo con las referencias aprobadas...
    python "Scripts\build-gallery.py"
) else (
    echo   Generando galeria con las capturas de: %~1
    python "Scripts\build-gallery.py" --screenshots "%~1"
)

if errorlevel 1 (
    echo.
    echo   [ERROR] No se pudo generar la galeria.
    popd
    pause
    exit /b 1
)

echo.
echo   Abriendo en el navegador...
start "" "%PROYECTO%\gallery\index.html"

echo.
echo   Recuerda: esto es una vista previa visual.
echo   La validacion real se ejecuta en iOS Simulator mediante CI macOS.
echo.
popd
endlocal
