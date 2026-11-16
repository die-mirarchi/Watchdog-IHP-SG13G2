v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 100 -290 120 -290 {lab=CLK}
N 100 -260 120 -260 {lab=CLK_LOST}
N 120 -200 120 -150 {lab=VDD}
N 120 -120 140 -120 {lab=VDD}
N 140 -200 140 -120 {lab=VDD}
N 60 -120 80 -120 {lab=G}
N 60 -120 60 -70 {lab=G}
N 60 -70 120 -70 {lab=G}
N 120 -90 120 -70 {lab=G}
N 120 70 120 80 {lab=NS[28:0],VSS}
N 60 40 80 40 {lab=VDD}
N 120 40 140 40 {lab=VSS}
N 140 40 140 100 {lab=VSS}
N 320 -170 320 -150 {lab=VDD,P1[2:0]}
N 320 -120 340 -120 {lab=VDD}
N 340 -200 340 -120 {lab=VDD}
N 260 -120 280 -120 {lab=G}
N 320 -90 320 -80 {lab=P1[2:0],A}
N 320 -40 320 -10 {lab=A}
N 320 50 320 100 {lab=VSS}
N 320 -40 500 -40 {lab=A}
N 500 -40 500 -10 {lab=A}
N 500 50 500 100 {lab=VSS}
N 500 20 520 20 {lab=VSS}
N 520 20 520 100 {lab=VSS}
N 440 20 460 20 {lab=CLKP}
N 500 -40 540 -40 {lab=A}
N 660 -170 660 -150 {lab=VDD,P2[2:0]}
N 660 -120 680 -120 {lab=VDD}
N 680 -200 680 -120 {lab=VDD}
N 600 -120 620 -120 {lab=G}
N 660 -90 660 -80 {lab=P2[2:0],B}
N 660 -40 660 -10 {lab=B}
N 660 50 660 100 {lab=VSS}
N 660 -40 840 -40 {lab=B}
N 840 -40 840 -10 {lab=B}
N 840 50 840 100 {lab=VSS}
N 840 20 860 20 {lab=VSS}
N 860 20 860 100 {lab=VSS}
N 780 20 800 20 {lab=CLKN}
N 840 -40 880 -40 {lab=B}
N 270 170 290 170 {lab=CLK}
N 370 170 410 170 {lab=CLKN}
N 410 170 450 170 {lab=CLKN}
N 410 170 410 200 {lab=CLKN}
N 530 170 550 170 {lab=CLKP}
N 760 -190 780 -190 {lab=A}
N 760 -110 780 -110 {lab=B}
N 960 -190 980 -190 {lab=SA}
N 980 -190 980 -170 {lab=SA}
N 980 -170 1000 -170 {lab=SA}
N 960 -110 980 -110 {lab=SB}
N 980 -130 980 -110 {lab=SB}
N 980 -130 1000 -130 {lab=SB}
N 1120 -150 1140 -150 {lab=CLK_LOST}
N 20 -200 120 -200 {lab=VDD}
N 120 -200 140 -200 {lab=VDD}
N 120 100 140 100 {lab=VSS}
N 140 -200 320 -200 {lab=VDD}
N 320 -200 340 -200 {lab=VDD}
N 140 100 320 100 {lab=VSS}
N 320 100 500 100 {lab=VSS}
N 500 100 520 100 {lab=VSS}
N 340 -200 660 -200 {lab=VDD}
N 660 -200 680 -200 {lab=VDD}
N 520 100 660 100 {lab=VSS}
N 660 100 840 100 {lab=VSS}
N 840 100 860 100 {lab=VSS}
N 120 -10 120 10 {lab=G,NS[28:0]}
N 20 100 120 100 {lab=VSS}
N 120 -70 260 -70 {lab=G}
N 260 -120 260 -70 {lab=G}
N 260 -70 600 -70 {lab=G}
N 600 -120 600 -70 {lab=G}
C {ipin.sym} 100 -290 0 0 {name=p1 lab=CLK}
C {lab_pin.sym} 120 -290 0 1 {name=l1 sig_type=std_logic lab=CLK}
C {opin.sym} 120 -260 0 0 {name=p2 lab=CLK_LOST}
C {lab_pin.sym} 100 -260 0 0 {name=l2 sig_type=std_logic lab=CLK_LOST}
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
C {sg13g2_pr/sg13_lv_nmos.sym} 100 40 0 0 {name=MN0[29:0]
l=10u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 60 40 0 0 {name=l8 sig_type=std_logic lab=VDD}
C {sg13g2_pr/sg13_lv_pmos.sym} 300 -120 0 0 {name=MP1[3:0]
l=10u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
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
C {sg13g2_pr/sg13_lv_pmos.sym} 640 -120 0 0 {name=MP2[3:0]
l=10u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
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
C {sg13g2_inv_1.sym} 330 170 0 0 {name=xi1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_inv_1.sym} 490 170 0 0 {name=xi2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 270 170 0 0 {name=l15 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 410 200 0 1 {name=l16 sig_type=std_logic lab=CLKN}
C {lab_pin.sym} 550 170 0 1 {name=l17 sig_type=std_logic lab=CLKP}
C {schmitt.sym} 930 -190 0 0 {name=xsa VDD=VDD VSS=VSS}
C {schmitt.sym} 930 -110 0 0 {name=xsb VDD=VDD VSS=VSS}
C {lab_pin.sym} 760 -190 0 0 {name=l18 sig_type=std_logic lab=A}
C {lab_pin.sym} 760 -110 0 0 {name=l19 sig_type=std_logic lab=B}
C {sg13g2_nand2_1.sym} 1060 -150 0 0 {name=xn VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 980 -190 0 1 {name=l20 sig_type=std_logic lab=SA}
C {lab_pin.sym} 980 -110 0 1 {name=l21 sig_type=std_logic lab=SB}
C {lab_pin.sym} 1140 -150 0 1 {name=l22 sig_type=std_logic lab=CLK_LOST}
C {lab_pin.sym} 320 -170 0 1 {name=lv1 sig_type=std_logic lab=VDD,P1[2:0]}
C {lab_pin.sym} 320 -80 0 1 {name=ld1 sig_type=std_logic lab=P1[2:0],A}
C {lab_pin.sym} 660 -170 0 1 {name=lv2 sig_type=std_logic lab=VDD,P2[2:0]}
C {lab_pin.sym} 660 -80 0 1 {name=ld2 sig_type=std_logic lab=P2[2:0],B}
C {lab_pin.sym} 120 -10 0 1 {name=l6 sig_type=std_logic lab=G,NS[28:0]}
C {lab_pin.sym} 120 80 0 0 {name=l7 sig_type=std_logic lab=NS[28:0],VSS}
