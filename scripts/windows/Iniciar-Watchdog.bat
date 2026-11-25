@echo off
setlocal

set "WSL_EXE=%SystemRoot%\System32\wsl.exe"
if exist "%SystemRoot%\Sysnative\wsl.exe" set "WSL_EXE=%SystemRoot%\Sysnative\wsl.exe"
set "WSL_DISTRO=Ubuntu-24.04"
set "LINUX_USER=eamtastudent"
set "STARTDIR=/mnt/d/Watchdog-IHP_Tesis/Watchdog-IHP-SG13G2"
set "PDK_DIR=/home/eamtastudent/tesis/Watchdog-IHP-SG13G2/.local/pdks/IHP-Open-PDK"
set "ACTION=shell"
if /i "%~1"=="--check" set "ACTION=check"

if not exist "%WSL_EXE%" (
    echo ERROR: No se encontro wsl.exe.
    pause
    exit /b 1
)

echo Iniciando entorno de tesis Watchdog IHP SG13G2...
echo Distribucion WSL: %WSL_DISTRO%
echo Proyecto: %STARTDIR%
echo.
echo Dentro del contenedor, para abrir la pagina inicial de IHP:
echo   xschem ^&
echo.
echo Para abrir KLayout:
echo   klayout -e ^&
echo.

"%WSL_EXE%" -d %WSL_DISTRO% -u %LINUX_USER% --cd %STARTDIR% -- env WD_PDK=%PDK_DIR% bash scripts/eda.sh %ACTION%
set "RESULT=%ERRORLEVEL%"

if /i "%~1"=="--check" exit /b %RESULT%
echo.
if not "%RESULT%"=="0" (
    echo ERROR: El entorno termino con codigo %RESULT%.
    echo Distribuciones registradas para este usuario de Windows:
    "%WSL_EXE%" --list --verbose
    echo Usuario de Windows:
    whoami
)
echo La sesion termino.
pause
exit /b %RESULT%
