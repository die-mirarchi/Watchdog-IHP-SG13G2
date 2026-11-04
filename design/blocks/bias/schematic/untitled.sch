v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -130 -20 -90 -20 {lab=#net1}
C {comp_sup.sym} 60 0 0 0 {name=x1 VDD=VDD VSS=VSS}
C {bias.sym} -280 -30 0 0 {name=x2 VDD=VDD VSS=VSS}
C {simulator_commands_shown.sym} -670 -190 0 0 {
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
C {simulator_commands_shown.sym} -680 10 0 0 {name=SimulatorNGSPICE
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
