v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 120 0 150 0 {lab=POR_RAW_N}
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
.param vdd=1.2
.temp 27
.option method=gear maxord=2 reltol=1e-3
** fuentes
VVDD VDD 0 PULSE(0 \{vdd\} 1u 1u 0.1u 5u 10u)
VVSS VSS 0 DC 0
.control
  set num_threads=1
  * ---- TRAN ----
  tran 1n 11u 0 0.1u
  let idd = -1
  meas tran idd AVG i(VVDD)
  let idd_ua = -1
  if (idd ne -1)
    let idd_ua = -idd*1e6
  end
  echo '  idd_ua = $&idd_ua'
  plot v(VDD)
  plot -i(VVDD)*1e6
  write wd_por.raw
.endc
"}
C {devices/lab_pin.sym} 150 0 0 1 {name=l_EDGE lab=POR_RAW_N}
