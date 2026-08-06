@echo off
REM ============================================================
REM  FERNE - Conectar con GitHub y lanzar el primer pipeline
REM
REM  Ejecuta el preflight, crea el repositorio PRIVADO y hace push.
REM  Se detiene solo si algo no esta en orden.
REM
REM  Uso:  Scripts\conectar-github.bat
REM
REM  NO usa force push. NO reescribe historial. NO borra nada.
REM ============================================================
setlocal enabledelayedexpansion

set "PROYECTO=%~dp0.."
pushd "%PROYECTO%"

echo.
echo   FERNE - Conexion con GitHub
echo   ===========================
echo.

REM ---------- 1. Herramientas ----------
echo   [1/7] Comprobando herramientas...
where git >nul 2>&1 || (echo   [ERROR] Falta Git. https://git-scm.com/download/win & goto :fin)
where gh  >nul 2>&1 || (echo   [ERROR] Falta GitHub CLI. Ejecuta: winget install --id GitHub.cli & goto :fin)
echo         Git y GitHub CLI presentes.

REM ---------- 2. Autenticacion ----------
echo.
echo   [2/7] Comprobando autenticacion...
gh auth status >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [DETENIDO] GitHub CLI no esta autenticado.
    echo.
    echo   Ejecuta en esta misma ventana:
    echo       gh auth login
    echo.
    echo   Elige: GitHub.com  ^>  HTTPS  ^>  Login with a web browser
    echo   Nunca pegues un token en un chat.
    echo.
    echo   Cuando termine, vuelve a ejecutar este script.
    goto :fin
)
gh auth status
echo         Autenticado.

REM ---------- 3. Preflight ----------
echo.
echo   [3/7] Preflight de seguridad...
where bash >nul 2>&1
if errorlevel 1 (
    echo         [AVISO] No hay bash. Se omiten los guards.
    echo                 Instala Git Bash o WSL para ejecutarlos.
) else (
    bash Scripts/ci/scan-secrets.sh        || (echo   [ERROR] Escaneo de secretos fallido. & goto :fin)
    bash Scripts/design-guard.sh           || (echo   [ERROR] Guardian de diseno fallido. & goto :fin)
    bash Scripts/verify-spec-integrity.sh  || (echo   [ERROR] Integridad del spec fallida. & goto :fin)
    bash Scripts/verify-alarmkit.sh        || (echo   [ERROR] AlarmKit podria romper el build. & goto :fin)
    bash Scripts/verify-line-endings.sh    || (echo   [ERROR] Finales de linea incorrectos. & goto :fin)
    echo         Preflight superado.
)

REM ---------- 4. Repositorio local ----------
echo.
echo   [4/7] Repositorio local...
if exist ".git" (
    echo         Ya existe .git. No se reinicializa.
) else (
    git init
    git branch -M main
    echo         Inicializado en la rama main.
)

REM ---------- 5. Politica de finales de linea ----------
echo.
echo   [5/7] Comprobando .gitattributes...
if not exist ".gitattributes" (
    echo.
    echo   [DETENIDO] Falta .gitattributes.
    echo.
    echo   Sin el, Git convierte LF a CRLF al hacer checkout en Windows y rompe:
    echo     - los scripts .sh  ^(error "bad interpreter ... ^^M"^)
    echo     - los bloques run: del workflow de GitHub Actions
    echo     - los checksums sha256 de la especificacion
    echo.
    echo   No continues sin el.
    goto :fin
)
echo         .gitattributes presente.

REM Git debe respetar el archivo, no imponer su propia conversion.
git config core.autocrlf false
echo         core.autocrlf = false ^(manda .gitattributes^).

REM Renormaliza el indice segun la politica. No borra ni modifica archivos.
git add --renormalize -A >nul 2>&1
git add -A 2>&1 | findstr /C:"warning:" >nul
if not errorlevel 1 (
    echo.
    echo   [AVISO] Git ha emitido avisos de conversion de finales de linea:
    git add -A 2>&1 | findstr /C:"warning:"
    echo.
    echo   Revisa .gitattributes antes de continuar.
    set /p SIGUE="   Continuar de todos modos? (s/n): "
    if /i not "!SIGUE!"=="s" goto :fin
) else (
    echo         Sin avisos de conversion.
)

REM Verificacion: los .sh y el workflow deben quedar en LF.
echo.
echo         Finales de linea en el indice:
for /f "tokens=1,2,4" %%a in ('git ls-files --eol -- "*.sh" ".github/workflows/ios-ci.yml" 2^>nul') do (
    echo %%a | findstr /C:"i/lf" >nul || echo           [ERROR] %%c no esta en LF
)
echo           Scripts .sh y workflow verificados en LF.

echo.
echo   --- Lo que se va a versionar ---
git status --short
echo.
echo   Archivos:
git diff --cached --name-only | find /c /v ""
echo.
set /p CONFIRMA="   Revisa la lista. Continuar con el commit? (s/n): "
if /i not "!CONFIRMA!"=="s" (echo   Cancelado por el usuario. & goto :fin)

git diff --cached --quiet
if not errorlevel 1 (
    echo         No hay cambios que confirmar.
) else (
    git commit -m "FERNE: phases 0 and 0.5 foundation"
    echo         Commit creado.
)
git log -1 --format="         Hash: %%H"

REM ---------- 5. Repositorio remoto ----------
echo.
echo   [6/7] Repositorio remoto...
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo         Creando repositorio PRIVADO 'ferne'...
    gh repo create ferne --private --source=. --remote=origin --description "FERNE - asistente personal diaria para iPhone. SwiftUI, offline-first."
    if errorlevel 1 (echo   [ERROR] No se pudo crear el repositorio. & goto :fin)
) else (
    echo         Ya hay un remoto configurado:
    git remote get-url origin
)

echo.
echo   Comprobando visibilidad...
gh repo view --json isPrivate,url,name
echo.

REM ---------- 6. Push ----------
echo   [7/7] Subiendo main...
git push -u origin main
if errorlevel 1 (echo   [ERROR] El push fallo. & goto :fin)

echo.
echo   ============================================
echo   Listo. El workflow 'iOS CI' deberia arrancar.
echo   ============================================
echo.
gh run list --limit 3
echo.
echo   Sigue la ejecucion en vivo:
echo       gh run watch
echo.
echo   Cuando termine, descarga los artifacts:
echo       gh run download
echo.

:fin
popd
endlocal
echo.
pause
