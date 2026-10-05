#!/usr/bin/env bash
set -eo pipefail
source /etc/profile.d/iic-osic-tools-setup.sh
set -u
export HOME=/workspace/.local/home
export PDK_ROOT=/foss/pdks PDK=ihp-sg13g2
export PDKPATH="$PDK_ROOT/$PDK"
export STD_CELL_LIBRARY=sg13g2_stdcell
export SPICE_USERINIT_DIR="$PDKPATH/libs.tech/ngspice"
export KLAYOUT_HOME="$HOME/.klayout"
export KLAYOUT_PATH="$KLAYOUT_HOME:$PDKPATH/libs.tech/klayout:$PDKPATH/libs.tech/klayout/tech"
export PYTHONPATH="$PDKPATH/libs.tech/klayout/python:$PDKPATH/libs.tech/klayout/python/pycell4klayout-api/source/python:${PYTHONPATH:-}"
export KLAYOUT_PYTHONPATH="$PYTHONPATH"
export PYTHONPYCACHEPREFIX="$HOME/.cache/python"
export XDG_CONFIG_HOME="$HOME/.config" XDG_CACHE_HOME="$HOME/.cache"
export QT_X11_NO_MITSHM=1
mkdir -p "$KLAYOUT_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" /workspace/build/netlist
cd /workspace
action=${1:-shell}
if [[ $# -gt 0 ]]; then shift; fi
case "$action" in
    check) exec python3 scripts/check_environment.py "$@" ;;
    xschem) [[ -n ${DISPLAY:-} ]] || { echo 'No hay DISPLAY. Abrir desde WSLg o una sesión gráfica Linux.' >&2; exit 1; }
        exec xschem --rcfile /workspace/xschemrc "$@" ;;
    klayout) [[ -n ${DISPLAY:-} ]] || { echo 'No hay DISPLAY. Abrir desde WSLg o una sesión gráfica Linux.' >&2; exit 1; }
        exec klayout -e -nn "$PDKPATH/libs.tech/klayout/tech/sg13g2.lyt" "$@" ;;
    shell) exec bash --noprofile --norc "$@" ;;
    *) exec "$action" "$@" ;;
esac
