# Watchdog IHP SG13G2

Base limpia para desarrollar una tesis de watchdog para microcontrolador en IHP
SG13G2. Derivada de [EAMTA2026-VLSI](https://github.com/Fundacion-Fulgor/EAMTA2026-VLSI),
conservando historial y licencia. Repositorio de tesis independiente del fork del curso.

**Estado inicial:** entorno preparado; diseño pendiente. Las carpetas de
esquemáticos y layouts están vacías. Ver [alcance](docs/ALCANCE.md).

## Instalar en otra PC

Windows: instalar WSL2 y Ubuntu 24.04 (`wsl --install -d Ubuntu-24.04` desde
PowerShell con permisos adecuados; reiniciar si Windows lo pide). Luego abrir
Ubuntu. Linux: usar Ubuntu 24.04 x86_64. Para ventanas gráficas se requiere WSLg
o una sesión X11/XWayland. Reservar al menos 30 GB de disco para herramientas.

Desde Ubuntu, **fuera de cualquier contenedor Distrobox**:

```bash
sudo apt-get update && sudo apt-get install -y git
mkdir -p ~/tesis
cd ~/tesis
git clone https://github.com/die-mirarchi/Watchdog-IHP-SG13G2.git
cd Watchdog-IHP-SG13G2
bash setup.sh
```

El instalador instala Podman si falta, descarga la imagen fija si hace falta y
ejecuta las pruebas de instalación. No requiere submódulos. El primer download
puede tardar; en esta PC reutiliza la imagen que ya estaba descargada.

## Uso diario

```bash
bash scripts/eda.sh xschem   # esquemáticos; abre vacío
bash scripts/eda.sh klayout  # layouts; abre vacío
bash scripts/eda.sh shell    # terminal con herramientas y PDK configurados
bash scripts/eda.sh check    # diagnóstico de instalación
```

En Windows con una Ubuntu que entra automáticamente a Distrobox, abrir el entorno
correcto desde PowerShell:

```powershell
wsl -d Ubuntu-24.04 -u eamtastudent --cd /home/eamtastudent/tesis/Watchdog-IHP-SG13G2 -- bash --noprofile --norc
```

En otra PC adaptar usuario y ruta. Dentro del contenedor el proyecto se encuentra
en `/workspace`. Guardar fuentes en `design/` o `verification/`; guardar archivos
de simulación y extracción en `build/` o `results/`.

## Organización

| Carpeta | Contenido |
|---|---|
| `design/blocks/` | input, oscillator, bias, comparator, por, digital, output |
| `design/top/` | Integración futura; schematic, layout, char |
| `verification/` | Bancos, vectores y planes de verificación futuros |
| `docs/thesis/` | Capítulos, figuras y referencias de la tesis |
| `docs/decisions/` | Decisiones de diseño |
| `docs/reports/` | Informes seleccionados para versionar |
| `tools-config/` | Versiones fijas del entorno |
| `scripts/` | Lanzador y comprobación de instalación |
| `build/`, `results/` | Resultados locales generados; excluidos de Git |
| `.local/` | Preferencias y cachés locales; excluidas de Git |

## Lanzador de Windows

Para esta instalaci�n, abrir con doble clic
`scripts/windows/Iniciar-Watchdog.bat` (tambi�n se puede copiar al escritorio).
Usa la distribuci�n WSL predeterminada y el usuario `eamtastudent`; el proyecto
se ubica en `/home/eamtastudent/tesis/Watchdog-IHP-SG13G2`. En otra PC, revisar
la distribuci�n predeterminada con `wsl --list --verbose` y adaptar las variables
`LINUX_USER` y `STARTDIR` del BAT si son diferentes.

El lanzador abre la terminal del contenedor en `/workspace`. Desde all�:

```bash
xschem /foss/pdks/ihp-sg13g2/libs.tech/xschem/start_page.sch &
klayout -e &
```

El primer comando abre la portada de IHP. `xschem &` abre una hoja nueva vac�a.
Para comprobar el arranque sin abrir una sesi�n interactiva, ejecutar el BAT
con el argumento `--check` desde PowerShell o CMD.

## Guardar y continuar en otra PC

Ejecutar Git desde Ubuntu, fuera del contenedor. Antes de cada commit revisar
`git status` y `git diff`. Agregar sólo fuentes y resultados seleccionados.

```bash
git add design verification docs
git commit -m "Describe el avance realizado"
git push
```

El clone HTTPS es público; para subir cambios configurar autenticación propia en
cada PC. Se puede usar SSH con `git remote set-url origin
git@github.com:die-mirarchi/Watchdog-IHP-SG13G2.git`. No copiar claves al repositorio.
En otra PC: clonar, ejecutar `bash setup.sh` y luego `git pull --ff-only` para
actualizar una copia existente. Los cambios sin commit/push no viajan con Git.

## Qué verifica el diagnóstico

Imagen y PDK fijados; carga de símbolos IHP en Xschem; punto de operación de un
NMOS IHP con ngspice y OSDI; tecnología y PCells IHP en KLayout; presencia de
reglas DRC/LVS y herramientas adicionales. Resultado en
`build/environment-check/report.json`, logs junto al informe.
No ejecuta DRC/LVS sobre un chip ni valida el watchdog: todavía no hay diseño.

Ver [procedencia](docs/PROVENANCE.md) y [solución de problemas](docs/TROUBLESHOOTING.md).
