v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -220 -30 -220 20 {lab=VBN}
N -340 290 -340 310 {lab=VSS}
N -340 0 -340 30 {lab=VDD}
N -340 110 -150 110 {lab=VH}
N -340 110 -340 130 {lab=VH}
N -340 210 -340 230 {lab=VL}
N -340 90 -340 110 {lab=VH}
N -150 60 -150 110 {lab=VH}
N -340 190 -340 210 {lab=VL}
N -200 -30 -200 210 {lab=VL}
N -220 20 -150 20 {lab=VBN}
N -340 210 -200 210 {lab=VL}
N -200 -30 -150 -30 {lab=VL}
N -220 -50 -150 -50 {lab=VBP}
N 240 80 390 80 {lab=CHG}
N 240 -40 270 -40 {lab=CHG}
N 150 -50 220 -50 {lab=SET}
N 220 -80 220 -50 {lab=SET}
N 220 -80 270 -80 {lab=SET}
N 210 20 270 20 {lab=RST}
N 250 60 270 60 {lab=NCHG}
N 250 -10 390 -10 {lab=NCHG}
N 250 -10 250 60 {lab=NCHG}
N 240 -40 240 80 {lab=CHG}
N 390 40 390 80 {lab=CHG}
N 770 -60 790 -60 {lab=DRIVE}
N 540 -160 730 -160 {lab=CLK}
N 460 -60 460 80 {lab=CHG}
N 750 -280 770 -280 {lab=CLK}
N -150 110 -120 110 {lab=VH}
N -200 210 -120 210 {lab=VL}
N -130 190 -120 190 {lab=VSS}
N -120 170 -120 190 {lab=VSS}
N -130 290 -120 290 {lab=VSS}
N -120 270 -120 290 {lab=VSS}
N 850 -60 910 -60 {lab=VC}
N 910 -60 910 -50 {lab=VC}
N 910 10 910 20 {lab=VSS}
N 910 -60 940 -60 {lab=VC}
N 770 -60 770 -30 {lab=DRIVE}
N 750 -60 770 -60 {lab=DRIVE}
N 390 80 460 80 {lab=CHG}
N 460 80 460 100 {lab=CHG}
N 390 -60 390 -10 {lab=NCHG}
N 210 20 210 40 {lab=RST}
N 150 20 210 20 {lab=RST}
N 460 -60 670 -60 {lab=CHG}
N 460 -160 460 -60 {lab=CHG}
C {bias.sym} -370 -40 0 0 {name=x1 VDD=VDD VSS=VSS}
C {comp_inf.sym} 0 -30 0 0 {name=x2 VDD=VDD VSS=VSS}
C {comp_sup.sym} 0 40 0 0 {name=x3 VDD=VDD VSS=VSS}
C {sg13g2_pr/rhigh.sym} -340 60 0 0 {name=R1
w=1e-6
l=450.0e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13g2_pr/rhigh.sym} -340 160 0 0 {name=R2
w=1e-6
l=450.0e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13g2_pr/rhigh.sym} -340 260 0 0 {name=R3
w=1e-6
l=450.0e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {lab_pin.sym} -340 0 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -340 310 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -150 -10 0 0 {name=p3 sig_type=std_logic lab=VC
}
C {lab_pin.sym} -150 40 0 0 {name=p4 sig_type=std_logic lab=VC
}
C {sg13g2_nor2_1.sym} 330 -60 0 0 {name=x4 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_nor2_1.sym} 330 40 0 0 {name=x5 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_buf_1.sym} 710 -60 0 0 {name=x6 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_buf_4.sym} 500 -160 0 0 {name=x7 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {opin.sym} 770 -280 0 0 {name=p6 lab=CLK}
C {lab_pin.sym} 750 -280 0 0 {name=p7 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} 730 -160 0 1 {name=p8 sig_type=std_logic lab=CLK
}
C {sg13g2_pr/rppd.sym} 820 -60 1 0 {name=R4
w=1e-6
l=338e-6
model=rppd
body=VSS
spiceprefix=X
b=15
 m=1
  mm_ok=1
value="expr_eng(  ( 70.0e-6 / @w + 260.0 * ( (@b + 1)* @l + ( 1.081*( @w + 6.0e-9 ) + 0.18e-6 )*@b ) / ( @w + 6.0e-9 ) ) / @m  )"
}
C {sg13g2_pr/cap_cmim.sym} -120 140 0 0 {name=C1
model=cap_cmim
 w=20.0e-6
 l=20.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/cap_cmim.sym} -120 240 0 0 {name=C3
model=cap_cmim
 w=20.0e-6
 l=20.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {lab_pin.sym} -130 290 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -130 190 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {sg13g2_pr/cap_cmim.sym} 910 -20 0 0 {name=C4
model=cap_cmim
 w=64.0e-6
 l=64.0e-6
 m=8
  mm_ok=1
 spiceprefix=X}
C {lab_pin.sym} 940 -60 0 1 {name=p11 sig_type=std_logic lab=VC
}
C {lab_pin.sym} 910 20 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -340 210 0 0 {name=p5 sig_type=std_logic lab=VL
}
C {lab_pin.sym} -340 110 0 0 {name=p13 sig_type=std_logic lab=VH
}
C {lab_pin.sym} 390 -60 0 1 {name=p14 sig_type=std_logic lab=NCHG
}
C {lab_pin.sym} 460 100 0 0 {name=p15 sig_type=std_logic lab=CHG
}
C {lab_pin.sym} 770 -30 0 0 {name=p16 sig_type=std_logic lab=DRIVE}
C {lab_pin.sym} 220 -80 0 0 {name=p17 sig_type=std_logic lab=SET
}
C {lab_pin.sym} 210 40 0 0 {name=p18 sig_type=std_logic lab=RST
}
C {lab_pin.sym} -220 20 0 0 {name=lbl_vbn sig_type=std_logic lab=VBN}
C {lab_pin.sym} -220 -50 0 0 {name=lbl_vbp sig_type=std_logic lab=VBP}
