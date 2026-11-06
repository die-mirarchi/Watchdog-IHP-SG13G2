v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 300 -20 310 -20 {lab=CLK}
C {wd_oscillater.sym} 150 -20 0 0 {name=x1 VDD=VDD VSS=VSS}
C {simulator_commands_shown.sym} -320 -170 0 0 {
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
C {simulator_commands_shown.sym} -610 60 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
* ===== TB wd_oscillator v3 : periodo sobre VC, glitches, metaestabilidad, retry =====
.param vdd=1.2
Vsup VDD 0 PWL(0 0 10u \{vdd\})
Vgnd VSS 0 0
.temp 27
.option method=gear maxord=2 gmin=1e-12 itl1=500 itl4=1000 rshunt=1e12
.save v(x1.chg) v(x1.vc) v(x1.vh) v(x1.vl) i(vsup)

.control
set wr_singlescale
set wr_vecnames
set hcopydevtype = svg
echo temp vdd lvl tend_ms T_us err_pct duty_pct glitch_pct tmid_ns tstart_us dVH_mV dVL_mV IDD_uA RESULT > osc_report.txt

foreach t -40 27 85
  foreach v 1.08 1.2 1.32
    alterparam vdd = $v

    * ---- nivel 1: estricto ----
    set lvl = 1
    reset
    option temp=$t reltol=5e-4 abstol=1e-12 vntol=1e-6 chgtol=1e-15
    tran 0.2u 1.2m 0 0.1u
    let tend = time[length(time)-1]

    * ---- nivel 2: intermedio ----
    if tend < 1.19e-3
      set lvl = 2
      reset
      option temp=$t reltol=2e-3 abstol=1e-11 vntol=1e-5 chgtol=1e-14
      tran 0.2u 1.2m 0 0.2u
      let tend = time[length(time)-1]
    end

    * ---- nivel 3: amplio ----
    if tend < 1.19e-3
      set lvl = 3
      reset
      option temp=$t reltol=5e-3 abstol=1e-10 vntol=1e-4 chgtol=1e-13 itl4=3000
      tran 0.2u 1.2m 0 0.2u
      let tend = time[length(time)-1]
    end

    let tend_ms = tend*1e3
    hardcopy osc_case_\{$t\}_\{$v\}.svg v(x1.vc) v(x1.vh) v(x1.vl) v(x1.chg)

    if tend < 1.19e-3
      echo $t $v $lvl $&tend_ms - - - - - - - - - ABORT >> osc_report.txt
    else
      let vm = $v/2
      * periodo sobre VC (sin glitches), 4 ciclos
      meas tran tvc  TRIG v(x1.vc)  VAL=$&vm RISE=3 TARG v(x1.vc)  VAL=$&vm RISE=7
      * mismos 4 ciclos contados sobre CHG (detecta flancos de mas)
      meas tran tchg TRIG v(x1.chg) VAL=$&vm RISE=4 TARG v(x1.chg) VAL=$&vm RISE=8
      meas tran thigh TRIG v(x1.chg) VAL=$&vm RISE=5 TARG v(x1.chg) VAL=$&vm FALL=5
      meas tran tstart WHEN v(x1.chg)=$&vm FALL=1 FROM=20u
      meas tran vcmax MAX v(x1.vc) FROM=0.6m TO=1.2m
      meas tran vcmin MIN v(x1.vc) FROM=0.6m TO=1.2m
      meas tran vh    AVG v(x1.vh) FROM=0.6m TO=1.2m
      meas tran vl    AVG v(x1.vl) FROM=0.6m TO=1.2m
      meas tran iavg  AVG i(vsup)  FROM=0.6m TO=1.2m
      let chgmid = (v(x1.chg) > 0.3*$v) & (v(x1.chg) < 0.7*$v)
      meas tran tmid INTEG chgmid FROM=0.15m TO=1.2m

      let T_us   = tvc/4*1e6
      let err    = T_us-100
      let duty   = 100*thigh/(tvc/4)
      let glitch = 100*abs(tchg-tvc)/tvc
      let tmidns = tmid*1e9
      let ts_us  = tstart*1e6
      let dvh    = (vcmax-vh)*1e3
      let dvl    = (vcmin-vl)*1e3
      let idd    = -iavg*1e6

      set res = PASS
      if abs(err) > 3
        set res = FAIL_T
      end
      if abs(duty-50) > 5
        set res = FAIL_DUTY
      end
      if ts_us > 200
        set res = FAIL_START
      end
      if abs(dvh) > 20
        set res = FAIL_VH
      end
      if abs(dvl) > 20
        set res = FAIL_VL
      end
      if idd > 15
        set res = FAIL_IDD
      end
      if tmidns > 200
        set res = FAIL_META
      end
      if glitch > 1
        set res = FAIL_GLITCH
      end
      echo $t $v $lvl $&tend_ms $&T_us $&err $&duty $&glitch $&tmidns $&ts_us $&dvh $&dvl $&idd $res >> osc_report.txt
    end
  end
end
echo listo >> osc_report.txt
shell cat osc_report.txt
.endc
"}
C {lab_pin.sym} 310 -20 0 1 {name=p8 sig_type=std_logic lab=CLK
}
