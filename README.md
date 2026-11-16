# Watchdog IHP SG13G2

Base limpia para desarrollar una tesis de watchdog para microcontrolador en IHP
SG13G2. Derivada de [EAMTA2026-VLSI](https://github.com/Fundacion-Fulgor/EAMTA2026-VLSI),
conservando historial y licencia. Repositorio de tesis independiente del fork del curso.

**Estado: versión 1.0 (16/11/2026).** Esquemáticos completos del watchdog,
dados por **funcionales y validados en simulación de esquemático** (ngspice +
PSP/OSDI e Icarus). La etapa siguiente es el **layout**. Ver
[diseño v1.0](#diseño--versión-10) y [alcance](docs/ALCANCE.md).

## Diseño — versión 1.0

Watchdog autónomo para microcontroladores, núcleo de 1,2 V en IHP SG13G2, con
reloj propio (oscilador RC de 10,24 kHz), reset de encendido propio y detector
de pérdida de reloj. El microcontrolador debe dar un flanco ascendente en
`WDI_IN` antes del timeout; si no, `RESET_OUT` = 1 durante 100 ms.

| Parámetro | Valor |
|---|---|
| Alimentación | VDD 1,2 V ±10 % (1,08–1,32 V) |
| Temperatura | −40 a 85 °C |
| Consumo | ≈ 8,9 µA (tt, 27 °C, 1,2 V); ≈ 6–14 µA en PVT |
| Reloj interno | 10,24 kHz (T = 97,66 µs); 96,95–99,0 µs en PVT con R/C típicos; −21…+24 % con esquinas de R/C |
| Timeout normal | `SET1 SET0` = 00 → 1 s, 01 → 0,1 s, 10 → 10 s, 11 → deshabilitado |
| Timeout de arranque | 10 s (tras encendido, tras cada pulso y tras una pérdida de reloj) |
| Pulso de reset | 100 ms (1025·T), `RESET_OUT` activo en alto |
| POR | sube 0,49–1,02 V, baja 0,39–0,81 V; `POR_B` se libera en el flanco 34 (≈ 3,3 ms) |
| Pérdida de reloj | detección 0,23–2,02 ms; reinicia el watchdog sin activar `RESET_OUT` |
| Dispositivos | CMOS lv (L ≤ 10 µm), rhigh, rppd, MIM (≈ 24 200 µm²); sin pads en el top |

Pines del top `wd_watchdog`: `SET1`, `SET0`, `WDI_IN`, `RESET_OUT`, `VDD`, `VSS`.

| Bloque | Carpeta | Función |
|---|---|---|
| `wd_watchdog` | `design/top/` | Top: integra los bloques; `POR_RAW_N = POR_DET_N · ¬CLK_LOST`; `RESET_OUT = RESET` |
| `wd_oscillater` | `design/blocks/oscillator/` | Oscilador de relajación RC ratiométrico (R<sub>T</sub> rppd 1/661, C<sub>T</sub> 4 MIM) |
| `bias`, `comp_sup`, `comp_inf`, `schmitt` | `bias/`, `comparator/`, `schmitt/` | Polarización, comparadores de dos etapas, inversor Schmitt 6T |
| `wd_por`, `wd_reset_sync` | `design/blocks/por/` | Detector de nivel de VDD y liberación síncrona del reset (34 flancos) |
| `WDI_INPUT` | `design/blocks/wd_input/` | Sincronizador de 2 FF y detector de flanco |
| `wd_digital` (`wd_control`, `counter17`, `one_bit`) | `digital/`, `counter_bit/` | Contador de 17 bits y máquina de control con configuración autorreparable |
| `wd_clkmon` | `design/blocks/clkmon/` | Detector de pérdida de reloj |

Verificación (detalle en `design/top/schematic/simulation/LEEME_simulacion_top.txt`):
lógica del top 38/38 chequeos y 5 654 058 ciclos sin diferencias contra el modelo;
oscilador 45/45 en PVT; POR + sincronizador 18/18 a nivel transistor;
`wd_clkmon` 34/34 en PVT; analógico del top 52/53 (la única falla es un
brown-out a 0,40 V en ff/85 °C/R wcs, pendiente de especificación).
No incluye parásitos de layout ni Monte Carlo.

Documentación de diseño (fuera del repositorio): «Esquemáticos y
dimensionamiento», «Documento de diseño», «Verificación del top» y «Detector de
pérdida de clock», versión 1.0.

Pendiente para el chip: anillo de pads (pull-downs de SET/WDI, salida de
drenador abierto), especificación de brown-out y de tolerancia de tiempos,
Monte Carlo, layout, DRC/LVS y extracción.

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
ejecuta las pruebas de instalación. El PDK se descarga en `.local/pdks/IHP-Open-PDK`, con sus submódulos, y sus seis modelos Verilog-A se compilan con OpenVAF. El primer download
puede tardar; en esta PC reutiliza la imagen que ya estaba descargada.

## Uso diario

```bash
bash scripts/eda.sh xschem   # esquem�ticos; abre la portada de IHP
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
| `design/blocks/` | oscillator, bias, comparator, schmitt, por, wd_input, digital, counter_bit, clkmon (v1.0); enable_input y output: historia / pendiente |
| `design/top/` | Top `wd_watchdog` (schematic) y bancos de simulación del top (`schematic/simulation/`) |
| `verification/` | Bancos de las celdas (barrido tt/ss) |
| `docs/thesis/` | Capítulos, figuras y referencias de la tesis |
| `docs/decisions/` | Decisiones de diseño |
| `docs/reports/` | Informes seleccionados para versionar |
| `tools-config/` | Versiones fijas del entorno |
| `scripts/` | Lanzador y comprobación de instalación |
| `build/`, `results/` | Resultados locales generados; excluidos de Git |
| `.local/` | Preferencias y cachés locales; excluidas de Git |

## Lanzador de Windows

Para esta instalaci�n, abrir con doble clic
`scripts/windows/Iniciar-Watchdog.bat` (se puede copiar al escritorio).
Usa la distribución WSL Ubuntu-24.04 y el usuario `eamtastudent`; el proyecto
se ubica en `/home/eamtastudent/tesis/Watchdog-IHP-SG13G2`. En otra PC, revisar
la distribuci�n predeterminada con `wsl --list --verbose` y adaptar las variables
`LINUX_USER` y `STARTDIR` del BAT si son diferentes.

El lanzador abre la terminal del contenedor en `/workspace`. Desde all�:

```bash
xschem &
klayout -e &
```

`xschem &` abre directamente la portada de IHP. Desde Xschem se puede crear
una hoja nueva para empezar un dise�o. La terminal muestra usuario, equipo y
carpeta actual (por ejemplo `eamtastudent@Dieguito:/workspace$`), con colores,
historial y autocompletado. La configuraci�n del proyecto se conserva aunque
se ejecute `xschem` desde una subcarpeta.

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
No ejecuta DRC/LVS sobre un chip ni valida el watchdog: la validación del diseño está en los bancos de `design/top/schematic/simulation/`.

Ver [procedencia](docs/PROVENANCE.md) y [solución de problemas](docs/TROUBLESHOOTING.md).

## PDK actualizado (10 de octubre de 2026)

El proyecto usa IHP Open PDK `main`, revisión
`5e6d592e4002946a4616f798c357f0f3c06cf3b6` (última de main consultada al instalar).
La imagen IIC-OSIC se fija por digest en `tools-config/toolchain.lock`.
`bash setup.sh` descarga la revisión fijada, inicializa submódulos, compila
los seis modelos OSDI y ejecuta las pruebas de instalación. El lanzador monta
este PDK local sobre `/foss/pdks/ihp-sg13g2`; no cambia el PDK de otros proyectos.

Para actualizar en el futuro, seleccionar una revisión oficial, modificar
`IHP_PDK_COMMIT` en el lock y volver a ejecutar `bash setup.sh`. Revisar el
informe antes de continuar un diseño. El script se detiene si detecta cambios
versionados en el PDK; no los descarta.

En esta PC, `C:\Users\Dieguito\Desktop\Tesis.bat` abre la terminal de
herramientas en `/workspace`. Para trabajar con Git desde Ubuntu anfitrión,
usar el comando WSL indicado más arriba. Los archivos reales del proyecto
están en `/home/eamtastudent/tesis/Watchdog-IHP-SG13G2`.

El diagnóstico se guarda en `build/environment-check/report.json`.
Ver también `docs/reports/instalacion-2026-10-10.md`.
