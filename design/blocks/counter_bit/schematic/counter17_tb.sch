v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 450 -30 470 -30 {lab=T00}
N 130 -30 150 -30 {lab=HI}
N 450 -10 470 -10 {lab=T10}
N 130 -10 150 -10 {lab=CLK}
N 130 10 150 10 {lab=CLR}
N 450 10 470 10 {lab=T01}
N 450 30 470 30 {lab=Q10_N}
N 130 30 150 30 {lab=POR_B}
C {simulator_commands_shown.sym} -490 -440 0 0 {
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
* counter17_tb -- validacion a nivel transistor de counter17 (IHP SG13G2)
* 17 x one_bit (D = (Q xor CI)&~CLR, CO = Q&CI), tomas T00 = Q13&Q11,
* T10 = Q16&Q15&Q12, T01 = Q10, Q10_N.
* Corner MOS: editar la linea .lib (mos_tt / mos_ss / ...)
* Barre T = -40/27/85 C  x  VDD = 1.08/1.2/1.32 V dentro de .control
* CLK = 50 MHz (celdas estaticas: la funcion no depende de f; con 1025 ciclos
* a 10 kHz la corrida seria de 100 ms). Flancos de subida en 10n + k*20n;
* entradas cambian en el flanco de bajada (20n + k*20n).
* Secuencia (k = numero de flanco):
*   k = 0        POR_B = 0                 -> cuenta 0 (reset asincronico)
*   k = 1..39    cuenta = k                -> se verifica Q0..Q5 en cada ciclo
*   k = 40, 41   CLR = 1                   -> cuenta 0 (borrado sincronico)
*   k = 42..51   cuenta = k - 41
*   t = 1050n    POR_B = 0 a mitad de ciclo con cuenta 10 -> Q3 y Q1 bajan sin flanco
* Las tomas (T01 = 1024, T00 = 10240, T10 = 102400 ciclos) no se alcanzan a nivel
* transistor en un tiempo razonable (>10 min por caso solo para T01): se verifican
* con el netlist exportado en Icarus (counter17_logic_tb.v). Aca se exige que
* T00, T10 y T01 no tengan glitches y que Q10_N quede en 1.
.global VDD VSS
.param vdd=1.2

* carga en las salidas: una entrada de celda (como en wd_control)
xl0 T00B T00 VDD VSS sg13g2_inv_1
xl1 T10B T10 VDD VSS sg13g2_inv_1
xl2 T01B T01 VDD VSS sg13g2_inv_1
xl3 Q10NB Q10_N VDD VSS sg13g2_inv_1

* ---------- fuentes ----------
V_VDD VDD 0 PWL(0 0 5n \{vdd\})
V_VSS VSS 0 0
V_HI  HI  0 \{vdd\}
V_CLK CLK 0 PULSE(0 \{vdd\} 10n 0.1n 0.1n 10n 20n)
V_POR POR_B 0 PWL(0 0 20n 0 20.01n \{vdd\} 1050n \{vdd\} 1050.01n 0)
V_CLR CLR   0 PWL(0 0 800n 0 800.01n \{vdd\} 840n \{vdd\} 840.01n 0)

.option method=gear maxord=2 reltol=1e-3
.save v(clk) v(clr) v(por_b) v(t00) v(t10) v(t01) v(q10_n) v(x1.q0) v(x1.q1) v(x1.q2) v(x1.q3) v(x1.q4) v(x1.q5)

.control
set noaskquit
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
  tran 0.1n 1100n 0 0.5n
  * reintento si ngspice aborta ('timestep too small' = artefacto numerico)
  let nt = length(time)
  let tend = time[nt-1]
  if tend lt 1090n
   echo REINTENTO T=$&tt VDD=$&vv con tmax=0.25n (aborto en t=$&tend)
   reset
   option temp = $&tt
   tran 0.05n 1100n 0 0.25n
  end
  let vh = vv/2
  * --- 1) cuenta en los bits 0..5 (muestreo a mitad de ciclo, 15 ns despues del flanco) ---
  let nok = 0
  let nchk = 0
  let k = 0
  while k lt 51
   let ts = 25n + k*20n
   if k lt 40
    let nexp = k
   else
    if k lt 42
     let nexp = 0
    else
     let nexp = k - 41
    end
   end
   meas tran b0 FIND v(x1.q0) AT=$&ts
   meas tran b1 FIND v(x1.q1) AT=$&ts
   meas tran b2 FIND v(x1.q2) AT=$&ts
   meas tran b3 FIND v(x1.q3) AT=$&ts
   meas tran b4 FIND v(x1.q4) AT=$&ts
   meas tran b5 FIND v(x1.q5) AT=$&ts
   let n = (b0 gt vh) + 2*(b1 gt vh) + 4*(b2 gt vh) + 8*(b3 gt vh) + 16*(b4 gt vh) + 32*(b5 gt vh)
   if n eq nexp
    let nok = nok + 1
   else
    echo FALLA cuenta: k=$&k leida=$&n esperada=$&nexp
   end
   let nchk = nchk + 1
   let k = k + 1
  end
  * --- 2) tomas sin glitches y Q10_N = 1 (cuenta < 1024) ---
  meas tran m00 MAX v(t00) FROM=30n TO=1040n
  meas tran m10 MAX v(t10) FROM=30n TO=1040n
  meas tran m01 MAX v(t01) FROM=30n TO=1040n
  meas tran mqn MIN v(q10_n) FROM=30n TO=1040n
  let p_tap = (m00 lt 0.3*vv) & (m10 lt 0.3*vv) & (m01 lt 0.3*vv) & (mqn gt 0.7*vv)
  * --- 3) tiempo CLK->Q del bit 0 (flanco 1, 30n) ---
  let tcq = -1
  meas tran tcq WHEN v(x1.q0)=$&vh RISE=1
  let dcq = (tcq - 30n)*1e9
  * --- 4) reset asincronico: POR_B baja en 1050n con cuenta 10 (Q3 = 1) ---
  meas tran q3a FIND v(x1.q3) AT=1045n
  let tra = -1
  meas tran tra WHEN v(x1.q3)=$&vh FALL=LAST
  let da = (tra - 1050n)*1e9
  let p_rst = (q3a gt vh) & (da gt 0) & (da lt 2)
  let pass = (nok eq nchk) & p_tap & p_rst & (dcq gt 0) & (dcq lt 2)
  if pass > 0.5
   echo CASO T=$&tt VDD=$&vv : PASS  cuenta=$&nok/$&nchk tCQ=$&dcq ns reset=$&da ns
   let npass = npass + 1
  else
   echo CASO T=$&tt VDD=$&vv : FAIL  cuenta=$&nok/$&nchk tomas=$&p_tap tCQ=$&dcq reset=$&p_rst
  end
  set wr_singlescale
  wrdata counter17_\{$&tt\}_\{$&vv\}.txt v(clk) v(clr) v(por_b) v(x1.q0) v(x1.q1) v(x1.q2) v(x1.q3)
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
C {counter17.sym} 300 0 0 0 {name=x1 VDD=VDD VSS=VSS}
C {lab_pin.sym} 470 -30 0 1 {name=l0 sig_type=std_logic lab=T00}
C {lab_pin.sym} 130 -30 0 0 {name=l1 sig_type=std_logic lab=HI}
C {lab_pin.sym} 470 -10 0 1 {name=l2 sig_type=std_logic lab=T10}
C {lab_pin.sym} 130 -10 0 0 {name=l3 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 130 10 0 0 {name=l4 sig_type=std_logic lab=CLR}
C {lab_pin.sym} 470 10 0 1 {name=l5 sig_type=std_logic lab=T01}
C {lab_pin.sym} 470 30 0 1 {name=l6 sig_type=std_logic lab=Q10_N}
C {lab_pin.sym} 130 30 0 0 {name=l7 sig_type=std_logic lab=POR_B}
