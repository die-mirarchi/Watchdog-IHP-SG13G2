** ---------------------------------------------------------------------------
** wd_reset_sync DIGITAL (XSPICE) SOLO PARA LA INTEGRACION.
** Como va antes que el netlist de Xschem, reemplaza al wd_reset_sync a nivel transistor
** (ngspice avisa "redefinition of .subckt wd_reset_sync, ignored": es lo esperado).
** El FF real (2 x sg13g2_dfrbp_1) esta validado aparte en tb_wd_reset_sync (45/45).
** Mismos pines y mismo nombre del nodo interno (P1).
** Umbral logico = VDD/2. Con VDD < 0.4 V los FF se consideran en reset (no funcionales).
** ---------------------------------------------------------------------------
.subckt wd_reset_sync POR_RAW_N CLK POR_B VDD VSS
BCK ckn 0 V = V(CLK,VSS)/max(V(VDD,VSS),0.05)
BRS rsn 0 V = (V(POR_RAW_N,VSS)/max(V(VDD,VSS),0.05))*0.5*(1+tanh((V(VDD,VSS)-0.4)/0.01))
AAD [ckn rsn] [dck drsn] adcb
AINV drsn drs dinv
APU dhi dpu
AF1 dhi dck NULL drs dp1 dp1n dff1
AF2 dp1 dck NULL drs dpb dpbn dff1
ADA [dp1 dpb] [p1n pbn] dacb
BP1 P1 VSS V = V(p1n)*V(VDD,VSS)
BPB POR_B VSS V = V(pbn)*V(VDD,VSS)
.model adcb adc_bridge(in_low=0.45 in_high=0.55 rise_delay=1e-11 fall_delay=1e-11)
.model dinv d_inverter(rise_delay=1e-11 fall_delay=1e-11)
.model dpu d_pullup(load=1e-12)
.model dff1 d_dff(clk_delay=300p set_delay=300p reset_delay=300p rise_delay=50p fall_delay=50p ic=0)
.model dacb dac_bridge(out_low=0 out_high=1 out_undef=0.5 t_rise=100p t_fall=100p)
.ends
