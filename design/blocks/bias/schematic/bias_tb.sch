v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 520 -20 520 10 {lab=VDD}
N 520 70 520 100 {lab=GND}
N 380 -70 410 -70 {lab=VBN}
N 380 -90 410 -90 {lab=VBP}
C {simulator_commands_shown.sym} -200 -230 0 0 {
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
C {simulator_commands_shown.sym} -210 -30 0 0 {name=SimulatorNGSPICE
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
C {bias.sym} 230 -80 0 0 {name=x1 VDD=VDD VSS=VSS}
C {devices/vsource.sym} 520 40 0 0 {name=V_VDD value="1.2"}
C {devices/lab_pin.sym} 520 -20 0 0 {name=src_VDD lab=VDD}
C {devices/gnd.sym} 520 100 0 0 {name=g_VDD lab=GND}
C {devices/vsource.sym} 520 -170 0 0 {name=V_VSS value=0}
C {devices/lab_pin.sym} 520 -200 0 0 {name=l_VSS lab=VSS}
C {devices/gnd.sym} 520 -140 0 0 {name=g_VSS lab=GND}
C {devices/lab_pin.sym} 410 -90 0 1 {name=l_EDGE lab=VBP}
C {devices/lab_pin.sym} 410 -70 0 1 {name=l_EDGE1 lab=VBN}
