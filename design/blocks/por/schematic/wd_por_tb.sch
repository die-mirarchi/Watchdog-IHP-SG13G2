v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 120 0 150 0 {lab=VBP}
C {wd_por.sym} -30 0 0 0 {name=x1 VDD=VDD VSS=VSS}
C {simulator_commands_shown.sym} -360 -160 0 0 {
name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_tt
.lib cornerMOShv.lib mos_tt
.lib cornerHBT.lib hbt_typ
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
.lib cornerCAP.lib cap_typ
"
      }
C {simulator_commands_shown.sym} -370 40 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
.temp 27
.control
save all
op
print v(VDD) v(VSS) v(VBN) v(VBP)
write bias_tb.raw
.endc
"}
C {devices/lab_pin.sym} 150 0 0 1 {name=l_EDGE lab=POR_RAW_N}
