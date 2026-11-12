#!/bin/sh
# Verificacion logica del top (Icarus + modelos Verilog de IHP). Bloques analogicos con modelos conductuales.
# Uso (desde esta carpeta, con PDK_ROOT definido, p. ej. /foss/pdks):
#   1) en xschem abrir wd_watchdog.sch y exportar el netlist -> simulation/wd_watchdog.spice
#   2) sh run_logic.sh [netlist]
N=${1:-wd_watchdog.spice}   # netlist exportado de wd_watchdog.sch
V=$PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog
S=$PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
python3 - "$V/sg13g2_stdcell.v" <<'PY'
import re,sys
t=open(sys.argv[1]).read()
t=re.sub(r'^\s*specify.*?^\s*endspecify',' ',t,flags=re.S|re.M)
def fix(m):
    b=m.group(0); ds=sorted(set(re.findall(r'\bdelayed_(\w+)',b)))
    return b.replace('endmodule',''.join(f'\tassign delayed_{d} = {d};\n' for d in ds)+'endmodule',1) if ds else b
open('cells_func.v','w').write(re.sub(r'module .*?endmodule',fix,t,flags=re.S))
PY
python3 spice2v.py $N $S wd_watchdog_net.v --skip wd_oscillater,wd_por,bias,comp_inf,comp_sup,schmitt || exit 1
iverilog -g2012 -o wd_watchdog_logic.vvp wd_watchdog_logic_tb.v wd_watchdog_net.v cells_func.v $V/sg13g2_udp.v || exit 1
vvp -n wd_watchdog_logic.vvp | tee wd_watchdog_logic.log
rm -f wd_watchdog_logic.vvp cells_func.v
