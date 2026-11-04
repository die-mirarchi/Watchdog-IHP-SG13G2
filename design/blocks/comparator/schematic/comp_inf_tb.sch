v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -190 -110 -170 -110 {lab=VBP}
N 360 -60 360 -30 {lab=VDD}
N 360 30 360 60 {lab=GND}
N -190 -150 -190 -110 {lab=VBP}
N -210 -110 -190 -110 {lab=VBP}
N 130 -110 150 -110 {lab=OUT}
N -180 -90 -170 -90 {lab=VP}
N -180 -70 -170 -70 {lab=VN}
C {bias.sym} -360 -120 0 0 {name=x2 VDD=VDD VSS=VSS}
C {simulator_commands_shown.sym} -750 -280 0 0 {
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
C {simulator_commands_shown.sym} -760 -80 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
* VP = referencia inferior VDD/3
* VN baja desde VP + 50 mV hasta VP - 50 mV
* Pendiente de descarga: aproximadamente -5.5 mV/us
VTEST_VP VP 0 DC 0.4
VTEST_VN VN VP DC 0.05 PWL(0 0.05 5u 0.05 23.18u -0.05 30u -0.05)

.control
pwd
echo Temp_C VDD_V Error_bajada_mV > comp_inf_corners.txt

foreach tc -40 27 85
  foreach vdd_val 1.08 1.20 1.32
    reset
    set temp = $tc

    let vp_ref = $vdd_val / 3
    alter V_VDD = $vdd_val
    alter VTEST_VP = $&vp_ref

    echo ---- T=$tc C  VDD=$vdd_val V ----
    tran 5n 30u 0 5n

    let out_half = $vdd_val / 2
    let error_mv = 1000 * (v(vn) - v(vp))
    meas tran error_bajada_mv FIND error_mv WHEN v(out)=$&out_half RISE=1 TD=5u
    echo $tc $vdd_val $&error_bajada_mv >> comp_inf_corners.txt
  end
end
.endc"}
C {devices/vsource.sym} 360 0 0 0 {name=V_VDD value="1.2"}
C {devices/lab_pin.sym} 360 -60 0 0 {name=src_VDD lab=VDD}
C {devices/gnd.sym} 360 60 0 0 {name=g_VDD lab=GND}
C {devices/vsource.sym} 360 -210 0 0 {name=V_VSS value=0}
C {devices/lab_pin.sym} 360 -240 0 0 {name=l_VSS lab=VSS}
C {devices/gnd.sym} 360 -180 0 0 {name=g_VSS lab=GND}
C {devices/lab_pin.sym} 150 -110 0 1 {name=l_EDGE lab=OUT
}
C {devices/lab_pin.sym} -190 -150 0 1 {name=l_EDGE1 lab=VBP}
C {devices/lab_pin.sym} -180 -90 0 0 {name=l_EDGE2 lab=VP
}
C {devices/lab_pin.sym} -180 -70 0 0 {name=l_EDGE3 lab=VN
}
C {comp_inf.sym} -20 -90 0 0 {name=x1 VDD=VDD VSS=VSS}
