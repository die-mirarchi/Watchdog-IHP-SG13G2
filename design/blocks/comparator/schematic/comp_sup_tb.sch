v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -110 -20 -90 -20 {lab=VBN}
N 440 30 440 60 {lab=VDD}
N 440 120 440 150 {lab=GND}
N -110 -60 -110 -20 {lab=VBN}
N -130 -20 -110 -20 {lab=VBN}
N 210 -20 230 -20 {lab=OUT}
N -100 -0 -90 -0 {lab=VP}
N -100 20 -90 20 {lab=VN}
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
* VP barre desde VN - 50 mV hasta VN + 50 mV
* Pendiente ascendente: aproximadamente 5.5 mV/us
VTEST_VN VN 0 DC 0.8
VTEST_VP VP VN DC -0.05 PWL(0 -0.05 5u -0.05 23.18u 0.05 30u 0.05)

.control
pwd
echo Temp_C VDD_V Error_subida_mV > comp_sup_corners.txt
foreach tc -40 27 85
  foreach vdd_val 1.08 1.20 1.32
    reset
    set temp = $tc

    let vn_ref = 2 * $vdd_val / 3
    alter V_VDD = $vdd_val
    alter VTEST_VN = $&vn_ref

    echo ---- T=$tc C  VDD=$vdd_val V ----
    tran 5n 30u 0 5n

    let out_half = $vdd_val / 2
    let error_mv = 1000 * (v(vp) - v(vn))
    meas tran error_subida_mv FIND error_mv WHEN v(out)=$&out_half RISE=1 TD=5u
    echo $tc $vdd_val $&error_subida_mv >> comp_sup_corners.txt
  end
end
.endc"}
C {devices/vsource.sym} 440 90 0 0 {name=V_VDD value="1.2"}
C {devices/lab_pin.sym} 440 30 0 0 {name=src_VDD lab=VDD}
C {devices/gnd.sym} 440 150 0 0 {name=g_VDD lab=GND}
C {devices/vsource.sym} 440 -120 0 0 {name=V_VSS value=0}
C {devices/lab_pin.sym} 440 -150 0 0 {name=l_VSS lab=VSS}
C {devices/gnd.sym} 440 -90 0 0 {name=g_VSS lab=GND}
C {devices/lab_pin.sym} 230 -20 0 1 {name=l_EDGE lab=OUT
}
C {devices/lab_pin.sym} -110 -60 0 1 {name=l_EDGE1 lab=VBN}
C {devices/lab_pin.sym} -100 0 0 0 {name=l_EDGE2 lab=VP
}
C {devices/lab_pin.sym} -100 20 0 0 {name=l_EDGE3 lab=VN
}
