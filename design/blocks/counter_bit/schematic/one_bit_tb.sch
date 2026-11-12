v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 420 -10 450 -10 {lab=Q}
N 100 -10 120 -10 {lab=POR_B}
N 100 50 120 50 {lab=CLR}
N 100 30 120 30 {lab=CI}
N 100 10 120 10 {lab=CLK}
C {simulator_commands_shown.sym} -460 -220 0 0 {
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
C {simulator_commands_shown.sym} -860 130 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
* ============================================================
* one_bit_tb.spice -- validacion funcional de one_bit (IHP SG13G2)
* D = (Q xor CI) and (not CLR) ; RESET_B asincronico = POR_B
* Corner MOS: editar la linea .lib (mos_tt / mos_ss / ...)
* Barre T = -40/27/85 C  x  VDD = 1.08/1.2/1.32 V dentro de .control
* CLK = 1 MHz (celda estatica: la funcion no depende de f; a 10 kHz
* ngspice da falsos flips del FF por paso de tiempo grande)
.global VDD VSS
.param vdd=1.2


* carga en Q: una entrada de celda (como el CI del bit siguiente)
xlq QB Q VDD VSS sg13g2_inv_1

* ---------- fuentes ----------
V_VDD VDD 0 PWL(0 0 100n \{vdd\})
V_VSS VSS 0 0
* CLK: flancos de subida en 0.5u + k*1u
V_CLK CLK 0 PULSE(0 \{vdd\} 0.5u 0.1n 0.1n 0.5u 1u)
* Entradas cambian en 0.2u + k*1u (300 ns de setup, 700 ns de hold)
V_POR POR_B 0 PWL(0 0 1.2u 0 1.2001u \{vdd\} 10.2u \{vdd\} 10.2001u 0 11.2u 0 11.2001u \{vdd\})
V_CI  CI    0 PWL(0 \{vdd\} 4.2u \{vdd\} 4.2001u 0 6.2u 0 6.2001u \{vdd\} 9.2u \{vdd\} 9.2001u 0 10.2u 0 10.2001u \{vdd\})
V_CLR CLR   0 PWL(0 0 6.2u 0 6.2001u \{vdd\} 8.2u \{vdd\} 8.2001u 0)

.option method=gear maxord=2 reltol=1e-3

.control
set noaskquit
* Secuencia esperada de Q (muestreo 300 ns despues de cada flanco):
*  E0   0.5u  POR_B=0, CI=1             -> 0  (reset domina)
*  E1   1.5u  CI=1 toggle               -> 1
*  E2   2.5u  CI=1 toggle               -> 0
*  E3   3.5u  CI=1 toggle               -> 1
*  E4   4.5u  CI=0 hold                 -> 1
*  E5   5.5u  CI=0 hold                 -> 1
*  E6   6.5u  CLR=1, CI=1 clear sincr.  -> 0
*  E7   7.5u  CLR=1 domina sobre CI     -> 0
*  E8   8.5u  CLR=0, CI=1 toggle        -> 1
*  E9   9.5u  CI=0 hold                 -> 1
*  A   10.3u  POR_B=0 en 10.2u (async)  -> 0  (sin flanco de CLK)
*  E10 10.5u  POR_B=0, CI=1             -> 0
*  E11 11.5u  POR_B=1, CI=1 toggle      -> 1
compose tchk values 0.8u 1.8u 2.8u 3.8u 4.8u 5.8u 6.8u 7.8u 8.8u 9.8u 10.3u 10.8u 11.8u
compose qexp values 0 1 0 1 1 1 0 0 1 1 0 0 1
let nchk = length(tchk)

compose tlist values -40 27 85
compose vlist values 1.08 1.2 1.32
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
  tran 0.5n 12u 0 1n
  * reintento si ngspice aborta ('timestep too small' = artefacto numerico)
  let nt = length(time)
  let tend = time[nt-1]
  if tend lt 11.9u
   echo REINTENTO T=$&tt VDD=$&vv con tmax=0.5n (aborto en t=$&tend)
   reset
   option temp = $&tt
   tran 0.25n 12u 0 0.5n
  end
  let vh = vv/2
  * --- 1) secuencia funcional ---
  let nok = 0
  let i = 0
  while i lt nchk
   let ts = tchk[i]
   meas tran qs FIND v(q) AT=$&ts
   let bit = qs gt vh
   let qe = qexp[i]
   if bit eq qe
    let nok = nok + 1
   else
    echo FALLA: t=$&ts Q=$&qs esperado=$&qe
   end
   let i = i + 1
  end
  * --- 2) sin glitches: exactamente 4 subidas y 3 bajadas de Q ---
  let r5 = -1
  let f4 = -1
  meas tran r5 WHEN v(q)=$&vh RISE=5
  meas tran f4 WHEN v(q)=$&vh FALL=4
  let noglitch = (r5 lt 0) & (f4 lt 0)
  * --- 3) tiempos: CLK->Q (E1) y POR_B->Q asincronico ---
  let tcq = -1
  let trq = -1
  meas tran tcq TRIG v(clk) VAL=$&vh RISE=2 TARG v(q) VAL=$&vh RISE=1
  meas tran trq TRIG v(por_b) VAL=$&vh FALL=1 TARG v(q) VAL=$&vh FALL=3
  * --- 4) Q_N complementaria ---
  meas tran qn1 FIND v(q_n) AT=11.8u
  meas tran qn0 FIND v(q_n) AT=7.8u
  let qnok = (qn1 lt vh) & (qn0 gt vh)
  let pass = (nok eq nchk) & noglitch & (tcq gt 0) & (tcq lt 1n) & (trq gt 0) & (trq lt 1n) & qnok
  let tcq_ps = tcq*1e12
  let trq_ps = trq*1e12
  if pass > 0.5
   echo CASO T=$&tt VDD=$&vv : PASS  muestras=$&nok/13 tCQ=$&tcq_ps ps tRST=$&trq_ps ps
   let npass = npass + 1
  else
   echo CASO T=$&tt VDD=$&vv : FAIL  muestras=$&nok/13 noglitch=$&noglitch tCQ=$&tcq_ps ps tRST=$&trq_ps ps QN=$&qnok
  end
  set wr_singlescale
  wrdata one_bit_\{$&tt\}_\{$&vv\}.txt v(clk) v(ci) v(clr) v(por_b) v(q)
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
C {devices/lab_pin.sym} 450 -10 0 1 {name=l_EDGE lab=CO}
C {devices/lab_pin.sym} 100 -10 0 0 {name=l_EDGE1 lab=POR_B}
C {devices/lab_pin.sym} 100 10 0 0 {name=l_EDGE2 lab=CLK}
C {devices/lab_pin.sym} 100 30 0 0 {name=l_EDGE3 lab=CI}
C {devices/lab_pin.sym} 100 50 0 0 {name=l_EDGE4 lab=CLR}
C {one_bit.sym} 270 20 0 0 {name=x1 VDD=VDD VSS=VSS}
