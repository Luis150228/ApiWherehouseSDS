@echo off
REM ===============================================
REM  Remove Backend Node Service (sin NSSM)
REM  Ejecutar como Administrador
REM ===============================================

set "SVC=backend-node"

echo Deteniendo servicio "%SVC%" (si existe)...
sc stop "%SVC%" >nul 2>&1

echo Eliminando servicio "%SVC%"...
sc delete "%SVC%"

echo Hecho.
pause
