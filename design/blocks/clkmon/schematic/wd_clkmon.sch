v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {wd_clkmon: detector de perdida de reloj (13/11/2026). CLK detenido en 0 o en 1 durante 0,3-1,9 ms -> CLK_LOST = 1; se libera con el primer flanco} -160 -420 0 0 0.4 0.4 {}
T {En el top: RESET_OUT = RESET + CLK_LOST (or2_1 fuera de POR_B). Bulks: PMOS a VDD, NMOS a VSS.} -160 -385 0 0 0.3 0.3 {}
T {Referencia} 20 -260 0 0 0.35 0.35 {}
T {MN0[14:0]: 15 x 0,15/20 en serie (L total 300 um), gate a VDD} -160 130 0 0 0.25 0.25 {}
T {I_REF ~ 50-180 nA en el diodo MP0} -160 150 0 0 0.25 0.25 {}
T {Integradores: MP1/MP2 copian ~ I_REF/67 (0,5-3,5 nA)} 300 -260 0 0 0.35 0.35 {}
T {CLK = 0: CA carga, CB en 0 (MN2 cerrado). CLK = 1: al reves} 300 -235 0 0 0.25 0.25 {}
T {CA, CB = cap_cmim 28 x 28 um (1,18 pF)} 300 130 0 0 0.25 0.25 {}
T {Fases a nivel de riel aunque CLK quede a media tension} 20 270 0 0 0.25 0.25 {}
T {Deteccion: V_A o V_B > V_T+ (0,64-0,84 V)} 980 -130 0 0 0.35 0.35 {}
T {Normal: SA = SB = 1 -> CLK_LOST = 0} 980 70 0 0 0.25 0.25 {}
N -160 -330 -140 -330 {lab=CLK}
N -160 -300 -140 -300 {lab=CLK_LOST}
N 20 -200 880 -200 {lab=VDD}
N 20 100 880 100 {lab=VSS}
N 120 -150 120 -200 {lab=VDD}
N 120 -120 140 -120 {lab=VDD}
N 140 -120 140 -200 {lab=VDD}
N 80 -120 60 -120 {lab=G}
N 60 -120 60 -70 {lab=G}
N 60 -70 120 -70 {lab=G}
N 120 -90 120 -70 {lab=G}
N 120 10 120 -10 {lab=G,NS[13:0]}
N 120 70 120 80 {lab=NS[13:0],VSS}
N 80 40 60 40 {lab=VDD}
N 120 40 140 40 {lab=VSS}
N 140 40 140 100 {lab=VSS}
N 320 -150 320 -200 {lab=VDD}
N 320 -120 340 -120 {lab=VDD}
N 340 -120 340 -200 {lab=VDD}
N 280 -120 260 -120 {lab=G}
N 320 -90 320 -40 {lab=A}
N 320 -40 320 -10 {lab=A}
N 320 50 320 100 {lab=VSS}
N 320 -40 500 -40 {lab=A}
N 500 -40 500 -10 {lab=A}
N 500 50 500 100 {lab=VSS}
N 500 20 520 20 {lab=VSS}
N 520 20 520 100 {lab=VSS}
N 460 20 440 20 {lab=CLKP}
N 500 -40 540 -40 {lab=A}
N 660 -150 660 -200 {lab=VDD}
N 660 -120 680 -120 {lab=VDD}
N 680 -120 680 -200 {lab=VDD}
N 620 -120 600 -120 {lab=G}
N 660 -90 660 -40 {lab=B}
N 660 -40 660 -10 {lab=B}
N 660 50 660 100 {lab=VSS}
N 660 -40 840 -40 {lab=B}
N 840 -40 840 -10 {lab=B}
N 840 50 840 100 {lab=VSS}
N 840 20 860 20 {lab=VSS}
N 860 20 860 100 {lab=VSS}
N 800 20 780 20 {lab=CLKN}
N 840 -40 880 -40 {lab=B}
N 60 220 80 220 {lab=CLK}
N 160 220 200 220 {lab=CLKN}
N 200 220 240 220 {lab=CLKN}
N 200 220 200 250 {lab=CLKN}
N 320 220 340 220 {lab=CLKP}
N 980 -60 1000 -60 {lab=A}
N 980 20 1000 20 {lab=B}
N 1180 -60 1200 -60 {lab=SA}
N 1200 -60 1200 -40 {lab=SA}
N 1200 -40 1220 -40 {lab=SA}
N 1180 20 1200 20 {lab=SB}
N 1200 20 1200 0 {lab=SB}
N 1200 0 1220 0 {lab=SB}
N 1340 -20 1360 -20 {lab=CLK_LOST}
C {ipin.sym} -160 -330 0 0 {name=p1 lab=CLK}
C {lab_pin.sym} -140 -330 0 1 {name=l1 sig_type=std_logic lab=CLK}
C {opin.sym} -140 -300 0 0 {name=p2 lab=CLK_LOST}
C {lab_pin.sym} -160 -300 0 0 {name=l2 sig_type=std_logic lab=CLK_LOST}
C {lab_pin.sym} 20 -200 0 0 {name=l3 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 20 100 0 0 {name=l4 sig_type=std_logic lab=VSS}
C {sg13g2_pr/sg13_lv_pmos.sym} 100 -120 0 0 {name=MP0
l=2u
w=0.5u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 60 -120 0 0 {name=l5 sig_type=std_logic lab=G}
C {sg13g2_pr/sg13_lv_nmos.sym} 100 40 0 0 {name=MN0[14:0]
l=20u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 120 -10 0 1 {name=l6 sig_type=std_logic lab=G,NS[13:0]}
C {lab_pin.sym} 120 80 0 0 {name=l7 sig_type=std_logic lab=NS[13:0],VSS}
C {lab_pin.sym} 60 40 0 0 {name=l8 sig_type=std_logic lab=VDD}
C {sg13g2_pr/sg13_lv_pmos.sym} 300 -120 0 0 {name=MP1
l=40u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 260 -120 0 0 {name=l9 sig_type=std_logic lab=G}
C {sg13g2_pr/cap_cmim.sym} 320 20 0 0 {name=CA
model=cap_cmim
 w=28e-6
 l=28e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/sg13_lv_nmos.sym} 480 20 0 0 {name=MN1
l=0.13u
w=0.5u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 440 20 0 0 {name=l10 sig_type=std_logic lab=CLKP}
C {lab_pin.sym} 540 -40 0 1 {name=l11 sig_type=std_logic lab=A}
C {sg13g2_pr/sg13_lv_pmos.sym} 640 -120 0 0 {name=MP2
l=40u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 600 -120 0 0 {name=l12 sig_type=std_logic lab=G}
C {sg13g2_pr/cap_cmim.sym} 660 20 0 0 {name=CB
model=cap_cmim
 w=28e-6
 l=28e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/sg13_lv_nmos.sym} 820 20 0 0 {name=MN2
l=0.13u
w=0.5u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 780 20 0 0 {name=l13 sig_type=std_logic lab=CLKN}
C {lab_pin.sym} 880 -40 0 1 {name=l14 sig_type=std_logic lab=B}
C {sg13g2_inv_1.sym} 120 220 0 0 {name=xi1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_inv_1.sym} 280 220 0 0 {name=xi2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 60 220 0 0 {name=l15 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 200 250 0 1 {name=l16 sig_type=std_logic lab=CLKN}
C {lab_pin.sym} 340 220 0 1 {name=l17 sig_type=std_logic lab=CLKP}
C {schmitt.sym} 1150 -60 0 0 {name=xsa VDD=VDD VSS=VSS}
C {schmitt.sym} 1150 20 0 0 {name=xsb VDD=VDD VSS=VSS}
C {lab_pin.sym} 980 -60 0 0 {name=l18 sig_type=std_logic lab=A}
C {lab_pin.sym} 980 20 0 0 {name=l19 sig_type=std_logic lab=B}
C {sg13g2_nand2_1.sym} 1280 -20 0 0 {name=xn VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 1200 -60 0 1 {name=l20 sig_type=std_logic lab=SA}
C {lab_pin.sym} 1200 20 0 1 {name=l21 sig_type=std_logic lab=SB}
C {lab_pin.sym} 1360 -20 0 1 {name=l22 sig_type=std_logic lab=CLK_LOST}
