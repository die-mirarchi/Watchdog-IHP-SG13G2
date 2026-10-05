@echo off
setlocal

set "WSL_EXE=%SystemRoot%\System32\wsl.exe"
if exist "%SystemRoot%\Sysnative\wsl.exe" set "WSL_EXE=%SystemRoot%\Sysnative\wsl.exe"
set "LINUX_USER=eamtastudent"
set "STARTDIR=/home/eamtastudent/tesis/Watchdog-IHP-SG13G2"
set "ACTION=shell"
if /i "%~1"=="--check" set "ACTION=check"

if not exist "%WSL_EXE%" (
    echo ERROR: No se encontro wsl.exe.
    pause
    exit /b 1
)

echo Iniciando entorno de tesis Watchdog IHP SG13G2...
echo Se usa la distribucion WSL predeterminada.
echo Proyecto: %STARTDIR%
echo.
echo Dentro del contenedor, para abrir la pagina inicial de IHP:
echo   xschem ^&
echo.
echo Para abrir KLayout:
echo   klayout -e ^&
echo.

"%WSL_EXE%" -u %LINUX_USER% --cd %STARTDIR% -- bash scripts/eda.sh %ACTION%
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
