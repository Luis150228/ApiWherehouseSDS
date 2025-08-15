@echo off
REM ==========================================================
REM  Backend Node Service Setup (sin NSSM) - ejecutar como Admin
REM  Edita SOLO las variables de esta sección según tus rutas.
REM ==========================================================

set "SVC=backendeut-node"
set "NODE=C:\node\node.exe"
set "SCRIPT=D:\dev\backend-offline\src\app.js"

echo.
echo === Configuracion ===
echo Servicio  : %SVC%
echo Node.exe  : %NODE%
echo Script    : %SCRIPT%
echo.

REM --- Validaciones basicas ---
if not exist "%NODE%" (
  echo [ERROR] No se encontro: %NODE%
  echo Edita este archivo y corrige la ruta.
  exit /b 1
)

if not exist "%SCRIPT%" (
  echo [ERROR] No se encontro: %SCRIPT%
  echo Edita este archivo y corrige la ruta.
  exit /b 1
)

echo Creando/actualizando servicio "%SVC%"...
REM Si ya existe, intenta eliminarlo antes (silencioso)
sc query "%SVC%" >nul 2>&1
if %ERRORLEVEL%==0 (
  echo Servicio ya existe. Deteniendo y eliminando para recrear...
  sc stop "%SVC%" >nul 2>&1
  sc delete "%SVC%" >nul 2>&1
  timeout /t 2 >nul
)

REM Crear servicio (auto-start)
sc create "%SVC%" binPath= "\"%NODE%\" \"%SCRIPT%\"" start= auto
if not %ERRORLEVEL%==0 (
  echo [ERROR] No se pudo crear el servicio. Ejecuta esta ventana como Administrador.
  exit /b 1
)

REM Descripcion
sc description "%SVC%" "Backend Node offline (Express + MariaDB)" >nul

REM Arranque diferido (Delayed Auto Start)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\%SVC%" /v DelayedAutoStart /t REG_DWORD /d 1 /f >nul

REM Recuperacion automatica (reinicios si falla)
sc failure "%SVC%" reset= 86400 actions= restart/5000/restart/5000/restart/5000 >nul
sc failureflag "%SVC%" 1 >nul

echo Iniciando servicio...
sc start "%SVC%"

echo.
echo === Estado del servicio ===
sc query "%SVC%"

echo.
echo Listo. Para probar en el servidor:  http://localhost:3000/health
echo Si necesitas quitarlo, usa: service-remove-backend-node.bat
echo.
pause
