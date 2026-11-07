v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 220 60 250 60 {lab=OUT}
N 20 60 40 60 {lab=IN}
C {simulator_commands_shown.sym} -390 -130 0 0 {
name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_ff
.lib cornerMOShv.lib mos_ff
.lib cornerHBT.lib hbt_typ
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
.lib cornerCAP.lib cap_typ
"
      }
C {simulator_commands_shown.sym} -640 80 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
* ===== TB schmitt : VT+, VT-, histeresis, niveles y flancos =====
.param vdd=1.2
Vsup VDD 0 \{vdd\}
Vgnd VSS 0 0
Vin  IN  0 PWL(0 0 10u \{vdd\} 20u 0)
Cl   OUT 0 5f
.option method=gear reltol=1e-3 abstol=1e-12
.save v(IN) v(OUT) i(vsup)

.control
set hcopydevtype = svg
echo temp vdd VTp VTm hys_mV VOH VOL tr_ps tf_ps RESULT > schmitt_report.txt
foreach t -40 27 85
  foreach v 1.08 1.2 1.32
    alterparam vdd = $v
    reset
    option temp = $t
    tran 2n 20u
    let vm  = $v/2
    let v10 = 0.1*$v
    let v90 = 0.9*$v
    meas tran vtp FIND v(IN) WHEN v(OUT)=$&vm FALL=1
    meas tran vtm FIND v(IN) WHEN v(OUT)=$&vm RISE=1
    meas tran voh MAX v(OUT) FROM=0 TO=2u
    meas tran vol MIN v(OUT) FROM=9u TO=11u
    meas tran tf TRIG v(OUT) VAL=$&v90 FALL=1 TARG v(OUT) VAL=$&v10 FALL=1
    meas tran tr TRIG v(OUT) VAL=$&v10 RISE=1 TARG v(OUT) VAL=$&v90 RISE=1
    let hys = (vtp-vtm)*1e3
    let trp = tr*1e12
    let tfp = tf*1e12
    set res = PASS
    if hys < 100
      set res = FAIL_HYS
    end
    if vtm < 0.15*$v
      set res = FAIL_VTM
    end
    if vtp > 0.85*$v
      set res = FAIL_VTP
    end
    if voh < 0.95*$v
      set res = FAIL_VOH
    end
    if vol > 0.05*$v
      set res = FAIL_VOL
    end
    if trp > 5000
      set res = FAIL_TR
    end
    if tfp > 5000
      set res = FAIL_TF
    end
    echo $t $v $&vtp $&vtm $&hys $&voh $&vol $&trp $&tfp $res >> schmitt_report.txt
    hardcopy schmitt_xy_\{$t\}_\{$v\}.svg v(OUT) vs v(IN)
  end
end
echo listo >> schmitt_report.txt
shell cat schmitt_report.txt
.endc
"}
C {devices/lab_pin.sym} 250 60 0 1 {name=l_EDGE lab=OUT}
C {devices/lab_pin.sym} 20 60 0 0 {name=l_EDGE1 lab=IN}
C {schmitt.sym} 190 60 0 0 {name=x1 VDD=VDD VSS=VSS}
