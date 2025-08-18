@echo off
set SERVICE=backendeut-node

echo ==== Control de servicio: %SERVICE% ====
sc query %SERVICE% | find "RUNNING" > nul
if %errorlevel%==0 (
    echo Servicio en ejecucion. Reiniciando...
    nssm restart %SERVICE%
    goto end
)

sc query %SERVICE% | find "STOPPED" > nul
if %errorlevel%==0 (
    echo Servicio detenido. Iniciando...
    nssm start %SERVICE%
    goto end
)

sc query %SERVICE% | find "PAUSED" > nul
if %errorlevel%==0 (
    echo Servicio en pausa. Reanudando...
    nssm continue %SERVICE%
    goto end
)

echo No se pudo determinar el estado del servicio. Revisa el nombre: %SERVICE%

:end
pause
