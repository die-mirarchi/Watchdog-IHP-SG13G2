#!/bin/sh
# Verificacion logica (Icarus + modelos Verilog de IHP) del netlist exportado por xschem.
# Uso (desde esta carpeta, con PDK_ROOT definido, p. ej. /foss/pdks):
#   1) en xschem abrir <celda>.sch y exportar el netlist (Netlist) -> simulation/<celda>.spice
#   2) sh run_logic.sh <celda>          (celda = counter17 o wd_control)
C=${1:?celda}
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
python3 spice2v.py $C.spice $S ${C}_net.v || exit 1
iverilog -g2012 -o ${C}_logic.vvp ${C}_logic_tb.v ${C}_net.v cells_func.v $V/sg13g2_udp.v || exit 1
vvp -n ${C}_logic.vvp | tee ${C}_logic.log
rm -f ${C}_logic.vvp cells_func.v
