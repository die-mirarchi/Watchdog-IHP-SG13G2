v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 90 -30 100 -30 {lab=POR_RAW_N}
N 90 0 100 0 {lab=CLK}
N 100 -10 100 0 {lab=CLK}
N 400 -30 410 -30 {lab=POR_B}
N 90 0 90 20 {lab=CLK}
N 80 -0 90 0 {lab=CLK}
N 90 -60 90 -30 {lab=POR_RAW_N}
N 80 -30 90 -30 {lab=POR_RAW_N}
N 400 -30 400 -10 {lab=POR_B}
N 400 -10 420 -10 {lab=POR_B}
N 420 50 420 60 {lab=VSS}
C {wd_por.sym} -70 -30 0 0 {name=x1 VDD=VDD VSS=VSS}
C {wd_reset_sync.sym} 250 -20 0 0 {name=x2 VDD=VDD VSS=VSS}
C {wd_oscillater.sym} -70 0 0 0 {name=x3 VDD=VDD VSS=VSS}
C {lab_pin.sym} 410 -30 0 1 {name=p2 sig_type=std_logic lab=POR_B
}
C {simulator_commands_shown.sym} -490 -170 0 0 {
name=Libs_Ngspice1
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
C {simulator_commands_shown.sym} -500 30 0 0 {name=SimulatorNGSPICE1
simulator=ngspice
only_toplevel=false 
value="
.param vdd=1.2
.temp 27
.option method=gear maxord=2 reltol=1e-3
** fuentes
VVDD VDD 0 PULSE(0 \{vdd\} 1u 1u 0.1u 300u 600u)
VVSS VSS 0 DC 0
.control
  set num_threads=1
  * ---- TRAN ----
  tran 50n 310u
  let idd = -1
  meas tran idd AVG i(VVDD)
  let idd_ua = -1
  if (idd ne -1)
    let idd_ua = -idd*1e6
  end
  echo '  idd_ua = $&idd_ua'
  plot v(VDD)
  plot -i(VVDD)*1e6
  write wd_reset_sync_tb.raw
.endc
"}
C {lab_pin.sym} 90 20 0 1 {name=p1 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} 90 -60 0 1 {name=p3 sig_type=std_logic lab=POR_RAW_N
}
C {capa.sym} 420 20 0 0 {name=C1
m=1
value=50f
footprint=1206
device="ceramic capacitor"}
C {devices/lab_pin.sym} 420 60 0 0 {name=l_VSS lab=VSS}
