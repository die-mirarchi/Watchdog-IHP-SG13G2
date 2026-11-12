v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 130 -90 150 -90 {lab=WDI_EDGE}
N 130 -70 150 -70 {lab=Q10_N}
N 130 -50 150 -50 {lab=T00}
N 130 -30 150 -30 {lab=T10}
N 130 -10 150 -10 {lab=CLK}
N 130 10 150 10 {lab=T01}
N 130 30 150 30 {lab=HI}
N 470 -90 450 -90 {lab=ACTIVE}
N 130 50 150 50 {lab=SET1}
N 470 -70 450 -70 {lab=BOOT}
N 470 -50 450 -50 {lab=CLR}
N 130 70 150 70 {lab=SET0}
N 470 -30 450 -30 {lab=RESET}
N 130 90 150 90 {lab=POR_B}
N 170 370 150 370 {lab=C0}
N -170 370 -150 370 {lab=POR_B}
N -170 390 -150 390 {lab=CLK}
N -170 410 -150 410 {lab=HI}
N -170 430 -150 430 {lab=CLR}
N 170 390 150 390 {lab=Q0}
N 170 410 150 410 {lab=Q0_N}
N 550 370 530 370 {lab=C1}
N 210 370 230 370 {lab=POR_B}
N 210 390 230 390 {lab=CLK}
N 210 410 230 410 {lab=C0}
N 210 430 230 430 {lab=CLR}
N 550 390 530 390 {lab=T01}
N 550 410 530 410 {lab=Q10_N}
N 930 370 910 370 {lab=C2}
N 590 370 610 370 {lab=POR_B}
N 590 390 610 390 {lab=CLK}
N 590 410 610 410 {lab=C1}
N 590 430 610 430 {lab=CLR}
N 930 390 910 390 {lab=Q2}
N 930 410 910 410 {lab=Q2_N}
N 1310 370 1290 370 {lab=C3}
N 970 370 990 370 {lab=POR_B}
N 970 390 990 390 {lab=CLK}
N 970 410 990 410 {lab=C2}
N 970 430 990 430 {lab=CLR}
N 1310 390 1290 390 {lab=Q3}
N 1310 410 1290 410 {lab=Q3_N}
N 1690 370 1670 370 {lab=C4}
N 1350 370 1370 370 {lab=POR_B}
N 1350 390 1370 390 {lab=CLK}
N 1350 410 1370 410 {lab=C3}
N 1350 430 1370 430 {lab=CLR}
N 1690 390 1670 390 {lab=Q4}
N 1690 410 1670 410 {lab=Q4_N}
N 2070 370 2050 370 {lab=C5}
N 1730 370 1750 370 {lab=POR_B}
N 1730 390 1750 390 {lab=CLK}
N 1730 410 1750 410 {lab=C4}
N 1730 430 1750 430 {lab=CLR}
N 2070 390 2050 390 {lab=Q5}
N 2070 410 2050 410 {lab=Q5_N}
N 620 180 640 180 {lab=Q3}
N 620 220 640 220 {lab=Q2}
N 780 200 760 200 {lab=T00}
N 820 160 840 160 {lab=Q5}
N 820 200 840 200 {lab=Q4}
N 820 240 840 240 {lab=Q2}
N 980 200 960 200 {lab=T10}
N 720 100 700 100 {lab=HI}
C {simulator_commands_shown.sym} -460 -260 0 0 {
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
C {simulator_commands_shown.sym} -1000 -260 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
* ============================================================
* wd_control_tb -- validacion a nivel transistor de wd_control (IHP SG13G2)
* Lazo cerrado con un contador ESCALADO de 6 bits hecho con one_bit (celdas reales):
*   T01 = Q1 (cuenta 2), T00 = Q3&Q2 (12), T10 = Q5&Q4&Q2 (52), Q10_N = Q1_N
*   -> pulso de reset 3 T, timeouts 13 / 3 / 53 T (SET = 00 / 01 / 10), arranque 53 T.
* Las constantes reales (1025 / 10241 / 102401 T) se verifican en Icarus con el
* netlist exportado (wd_control_logic_tb.v).
* Corner MOS: editar la linea .lib (mos_tt / mos_ss / ...)
* Barre T = -40/27/85 C  x  VDD = 1.08/1.2/1.32 V dentro de .control
* CLK 10 MHz: flancos de subida en 50n + k*100n; entradas cambian en 20n + k*100n.
* WDI_EDGE se da como pulsos de un ciclo (lo que entrega WDI_INPUT).
* Fases: A SET=00 (arranque sin WDI -> pulso -> WDI -> timeout normal)
*        B SET=01 (WDI en arranque -> timeout de 3 T; WDI en el ultimo ciclo es valido)
*        C SET=10 (WDI -> 53 T; SET cambiado en marcha a 11 no tiene efecto)
*        D SET=11 (deshabilitado, con WDI)
* Eventos esperados de RESET (subida/bajada, +-2 ns): 5350/5650, 7350/7650,
* 9050/9350, 15350/15650 ns; sin un quinto pulso. ACTIVE y BOOT en 6 instantes.
.global VDD VSS
.param vdd=1.2

* ---- contador escalado (6 x one_bit) y tomas: dibujados en el esquematico ----

* ---------- fuentes y cargas ----------
CRS RESET 0 10f
CAC ACTIVE 0 10f
CBT BOOT 0 10f
V_VDD VDD 0 PWL(0 0 100n \{vdd\})
V_VSS VSS 0 0
V_CLK CLK 0 PULSE(0 \{vdd\} 50n 0.1n 0.1n 50n 100n)
V_POR POR_B 0 PWL(0 0 120n 0 120.01n \{vdd\} 8020n \{vdd\} 8020.01n 0 8220n 0 8220.01n \{vdd\} 9720n \{vdd\} 9720.01n 0 9920n 0 9920.01n \{vdd\} 15720n \{vdd\} 15720.01n 0 15920n 0 15920.01n \{vdd\})
V_S0 SET0 0 PWL(0 0 8020n 0 8020.01n \{vdd\} 9720n \{vdd\} 9720.01n 0 10520n 0 10520.01n \{vdd\} 15720n \{vdd\} 15720.01n \{vdd\})
V_S1 SET1 0 PWL(0 0 9720n 0 9720.01n \{vdd\} 15720n \{vdd\} 15720.01n \{vdd\})
V_WDI WDI_EDGE 0 PWL(0 0 6020n 0 6020.01n \{vdd\} 6120n \{vdd\} 6120.01n 0 8420n 0 8420.01n \{vdd\} 8520n \{vdd\} 8520.01n 0 8720n 0 8720.01n \{vdd\} 8820n \{vdd\} 8820.01n 0 10020n 0 10020.01n \{vdd\} 10120n \{vdd\} 10120.01n 0 16520n 0 16520.01n \{vdd\} 16620n \{vdd\} 16620.01n 0)
.option method=gear maxord=2 reltol=1e-3
* guardar solo lo necesario: con todos los nodos ngspice acumula ~3 GB en 9 casos
.save v(clk) v(por_b) v(set0) v(set1) v(wdi_edge) v(active) v(boot) v(reset)
.control
set noaskquit
compose tlist values -40 27 85
compose vlist values 1.08 1.2 1.32
compose rexp values 5350n 7350n 9050n 15350n
compose fexp values 5650n 7650n 9350n 15650n
let npass = 0
let ncase = 0
let it = 0
while it lt 3
 let iv = 0
 while iv lt 3
  let tt = tlist[it]
  let vv = vlist[iv]
  alterparam vdd = $&vv
  reset
  option temp = $&tt
  tran 0.1n 21000n 0 0.5n
  let nt = length(time)
  let tend = time[nt-1]
  if tend lt 20990n
   echo REINTENTO T=$&tt VDD=$&vv (aborto en t=$&tend)
   reset
   option temp = $&tt
   tran 0.05n 21000n 0 0.25n
  end
  let vh = vv/2
  let ok = 0
  let k = 0
  while k lt 4
   let kk = k + 1
   let tr = -1
   let tf = -1
   meas tran tr WHEN v(reset)=$&vh RISE=$&kk
   meas tran tf WHEN v(reset)=$&vh FALL=$&kk
   let er = abs(tr - rexp[k]) lt 2n
   let ef = abs(tf - fexp[k]) lt 2n
   if er & ef
    let ok = ok + 1
   else
    echo   evento $&kk : subida=$&tr bajada=$&tf
   end
   let k = k + 1
  end
  let r5 = -1
  meas tran r5 WHEN v(reset)=$&vh RISE=5
  meas tran a03 FIND v(active) AT=300n
  meas tran b03 FIND v(boot) AT=300n
  meas tran b70 FIND v(boot) AT=7000n
  meas tran b79 FIND v(boot) AT=7900n
  meas tran a18 FIND v(active) AT=18000n
  meas tran a20 FIND v(active) AT=20500n
  let lv = (a03 gt vh) & (b03 gt vh) & (b70 lt vh) & (b79 gt vh) & (a18 lt vh) & (a20 lt vh)
  let pass = (ok eq 4) & (r5 lt 0) & lv
  if pass > 0.5
   echo CASO T=$&tt VDD=$&vv : PASS  4/4 eventos de RESET a +-2 ns, niveles ok
   let npass = npass + 1
  else
   echo CASO T=$&tt VDD=$&vv : FAIL  eventos=$&ok/4 sin5=$&r5 niveles=$&lv
  end
  set wr_singlescale
  wrdata wd_control_\{$&tt\}_\{$&vv\}.txt v(clk) v(por_b) v(set0) v(set1) v(wdi_edge) v(active) v(boot) v(reset)
  destroy all
  let ncase = ncase + 1
  let iv = iv + 1
 end
 let it = it + 1
end
echo ===============================================
echo RESUMEN: $&npass / $&ncase casos PASS
if npass eq ncase
 echo VEREDICTO: PASS
else
 echo VEREDICTO: FAIL
end
.endc
.end"}
C {wd_control.sym} 300 0 0 0 {name=x1 VDD=VDD VSS=VSS}
C {lab_pin.sym} 130 -90 0 0 {name=l0 sig_type=std_logic lab=WDI_EDGE}
C {lab_pin.sym} 130 -70 0 0 {name=l1 sig_type=std_logic lab=Q10_N}
C {lab_pin.sym} 130 -50 0 0 {name=l2 sig_type=std_logic lab=T00}
C {lab_pin.sym} 130 -30 0 0 {name=l3 sig_type=std_logic lab=T10}
C {lab_pin.sym} 130 -10 0 0 {name=l4 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 130 10 0 0 {name=l5 sig_type=std_logic lab=T01}
C {lab_pin.sym} 130 30 0 0 {name=l6 sig_type=std_logic lab=HI}
C {lab_pin.sym} 470 -90 0 1 {name=l7 sig_type=std_logic lab=ACTIVE}
C {lab_pin.sym} 130 50 0 0 {name=l8 sig_type=std_logic lab=SET1}
C {lab_pin.sym} 470 -70 0 1 {name=l9 sig_type=std_logic lab=BOOT}
C {lab_pin.sym} 470 -50 0 1 {name=l10 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 130 70 0 0 {name=l11 sig_type=std_logic lab=SET0}
C {lab_pin.sym} 470 -30 0 1 {name=l12 sig_type=std_logic lab=RESET}
C {lab_pin.sym} 130 90 0 0 {name=l13 sig_type=std_logic lab=POR_B}
C {one_bit.sym} 0 400 0 0 {name=xb0 VDD=VDD VSS=VSS}
C {lab_pin.sym} 170 370 0 1 {name=l14 sig_type=std_logic lab=C0}
C {lab_pin.sym} -170 370 0 0 {name=l15 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} -170 390 0 0 {name=l16 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -170 410 0 0 {name=l17 sig_type=std_logic lab=HI}
C {lab_pin.sym} -170 430 0 0 {name=l18 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 170 390 0 1 {name=l19 sig_type=std_logic lab=Q0}
C {lab_pin.sym} 170 410 0 1 {name=l20 sig_type=std_logic lab=Q0_N}
C {one_bit.sym} 380 400 0 0 {name=xb1 VDD=VDD VSS=VSS}
C {lab_pin.sym} 550 370 0 1 {name=l21 sig_type=std_logic lab=C1}
C {lab_pin.sym} 210 370 0 0 {name=l22 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 210 390 0 0 {name=l23 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 210 410 0 0 {name=l24 sig_type=std_logic lab=C0}
C {lab_pin.sym} 210 430 0 0 {name=l25 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 550 390 0 1 {name=l26 sig_type=std_logic lab=T01}
C {lab_pin.sym} 550 410 0 1 {name=l27 sig_type=std_logic lab=Q10_N}
C {one_bit.sym} 760 400 0 0 {name=xb2 VDD=VDD VSS=VSS}
C {lab_pin.sym} 930 370 0 1 {name=l28 sig_type=std_logic lab=C2}
C {lab_pin.sym} 590 370 0 0 {name=l29 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 590 390 0 0 {name=l30 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 590 410 0 0 {name=l31 sig_type=std_logic lab=C1}
C {lab_pin.sym} 590 430 0 0 {name=l32 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 930 390 0 1 {name=l33 sig_type=std_logic lab=Q2}
C {lab_pin.sym} 930 410 0 1 {name=l34 sig_type=std_logic lab=Q2_N}
C {one_bit.sym} 1140 400 0 0 {name=xb3 VDD=VDD VSS=VSS}
C {lab_pin.sym} 1310 370 0 1 {name=l35 sig_type=std_logic lab=C3}
C {lab_pin.sym} 970 370 0 0 {name=l36 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 970 390 0 0 {name=l37 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 970 410 0 0 {name=l38 sig_type=std_logic lab=C2}
C {lab_pin.sym} 970 430 0 0 {name=l39 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 1310 390 0 1 {name=l40 sig_type=std_logic lab=Q3}
C {lab_pin.sym} 1310 410 0 1 {name=l41 sig_type=std_logic lab=Q3_N}
C {one_bit.sym} 1520 400 0 0 {name=xb4 VDD=VDD VSS=VSS}
C {lab_pin.sym} 1690 370 0 1 {name=l42 sig_type=std_logic lab=C4}
C {lab_pin.sym} 1350 370 0 0 {name=l43 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 1350 390 0 0 {name=l44 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 1350 410 0 0 {name=l45 sig_type=std_logic lab=C3}
C {lab_pin.sym} 1350 430 0 0 {name=l46 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 1690 390 0 1 {name=l47 sig_type=std_logic lab=Q4}
C {lab_pin.sym} 1690 410 0 1 {name=l48 sig_type=std_logic lab=Q4_N}
C {one_bit.sym} 1900 400 0 0 {name=xb5 VDD=VDD VSS=VSS}
C {lab_pin.sym} 2070 370 0 1 {name=l49 sig_type=std_logic lab=C5}
C {lab_pin.sym} 1730 370 0 0 {name=l50 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 1730 390 0 0 {name=l51 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 1730 410 0 0 {name=l52 sig_type=std_logic lab=C4}
C {lab_pin.sym} 1730 430 0 0 {name=l53 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 2070 390 0 1 {name=l54 sig_type=std_logic lab=Q5}
C {lab_pin.sym} 2070 410 0 1 {name=l55 sig_type=std_logic lab=Q5_N}
C {sg13g2_and2_1.sym} 700 200 0 0 {name=xt0 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 620 180 0 0 {name=l56 sig_type=std_logic lab=Q3}
C {lab_pin.sym} 620 220 0 0 {name=l57 sig_type=std_logic lab=Q2}
C {lab_pin.sym} 780 200 0 1 {name=l58 sig_type=std_logic lab=T00}
C {sg13g2_and3_1.sym} 900 200 0 0 {name=xt1 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 820 160 0 0 {name=l59 sig_type=std_logic lab=Q5}
C {lab_pin.sym} 820 200 0 0 {name=l60 sig_type=std_logic lab=Q4}
C {lab_pin.sym} 820 240 0 0 {name=l61 sig_type=std_logic lab=Q2}
C {lab_pin.sym} 980 200 0 1 {name=l62 sig_type=std_logic lab=T10}
C {sg13g2_tiehi.sym} 700 100 0 0 {name=xth VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 720 100 0 1 {name=l63 sig_type=std_logic lab=HI}
