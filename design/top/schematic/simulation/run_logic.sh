#!/bin/sh
# Verificacion logica del top (Icarus + modelos Verilog de IHP). Bloques analogicos con modelos conductuales.
# Uso (desde esta carpeta, con PDK_ROOT definido, p. ej. /foss/pdks):
#   1) en xschem abrir wd_watchdog.sch y exportar el netlist -> simulation/wd_watchdog.spice
#   2) sh run_logic.sh [netlist] [tb] [+SET=n]
N=${1:-wd_watchdog.spice}   # netlist exportado de wd_watchdog.sch
TB=${2:-wd_watchdog_logic_tb.v}   # o wd_watchdog_plotset_tb.v (+SET=0..3) / wd_watchdog_wdi_tb.v /
                                  #   wd_watchdog_clkmon_tb.v / upset_tb.v (+B)
shift 2 2>/dev/null
V=$PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog
S=$PDK_ROOT/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
# upset_tb.v necesita el latch dllrq conductual (dllrq_beh.v) para poder forzar su estado
BEH=""; case "$TB" in upset_tb.v) BEH=dllrq_beh.v;; esac
python3 - "$V/sg13g2_stdcell.v" "$BEH" <<'PY'
import re,sys
t=open(sys.argv[1]).read()
t=re.sub(r'^\s*specify.*?^\s*endspecify',' ',t,flags=re.S|re.M)
def fix(m):
    b=m.group(0); ds=sorted(set(re.findall(r'\bdelayed_(\w+)',b)))
    return b.replace('endmodule',''.join(f'\tassign delayed_{d} = {d};\n' for d in ds)+'endmodule',1) if ds else b
t=re.sub(r'module .*?endmodule',fix,t,flags=re.S)
if sys.argv[2]: t=re.sub(r'module sg13g2_dllrq_1\b.*?endmodule','',t,flags=re.S)
open('cells_func.v','w').write(t)
PY
python3 spice2v.py $N $S wd_watchdog_net.v --skip wd_oscillater,wd_por,bias,comp_inf,comp_sup,schmitt,wd_clkmon || exit 1
# wd_clkmon_beh.v: modelo conductual del detector de perdida de reloj (CLK_LOST)
iverilog -g2012 -o wd_watchdog_logic.vvp $TB wd_watchdog_net.v cells_func.v wd_clkmon_beh.v $BEH $V/sg13g2_udp.v || exit 1
vvp -n wd_watchdog_logic.vvp "$@" | tee ${TB%_tb.v}.log
rm -f wd_watchdog_logic.vvp cells_func.v
