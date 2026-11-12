v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 120 -150 140 -150 {lab=POR_RAW_N}
N 0 0 0 20 {lab=VD}
N -20 90 0 90 {lab=VSS}
N 0 0 110 0 {lab=VD}
N 0 -20 0 0 {lab=VD}
N 110 -0 110 60 {lab=VD}
N 110 60 150 60 {lab=VD}
N -0 80 0 90 {lab=VSS}
N 0 90 200 90 {lab=VSS}
N 560 50 560 70 {lab=DELAY}
N 560 130 560 140 {lab=VSS}
N 680 -30 720 -30 {lab=VDD}
N 720 -30 720 -20 {lab=VDD}
N 680 -30 680 10 {lab=VDD}
N 560 50 720 50 {lab=DELAY}
N 720 40 720 50 {lab=DELAY}
N 720 60 770 60 {lab=DELAY}
N 720 50 720 60 {lab=DELAY}
N 700 100 770 100 {lab=VOK}
N 890 80 900 80 {lab=POR_RAW_N}
N 720 10 730 10 {lab=VDD}
N 730 -30 730 10 {lab=VDD}
N 720 -30 730 -30 {lab=VDD}
N 190 60 200 60 {lab=VSS}
N 200 60 200 90 {lab=VSS}
N 190 -20 190 30 {lab=X}
N -20 -80 720 -80 {lab=VDD}
N 370 -60 370 160 {lab=VOK}
N 450 -60 560 -60 {lab=#net1}
N 560 -60 560 -30 {lab=#net1}
N 700 100 700 160 {lab=VOK}
N 370 160 700 160 {lab=VOK}
N 560 30 560 50 {lab=DELAY}
N 720 -80 720 -30 {lab=VDD}
C {sg13g2_pr/rhigh.sym} 0 -50 0 0 {name=R1
w=0.5e-6
l=320e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13g2_pr/rhigh.sym} 0 50 0 0 {name=R2
w=0.5e-6
l=385e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {opin.sym} 140 -150 0 0 {name=p5 lab=POR_RAW_N}
C {lab_pin.sym} 120 -150 0 0 {name=p7 sig_type=std_logic lab=POR_RAW_N
}
C {lab_pin.sym} -20 -80 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -20 90 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {sg13g2_pr/sg13_lv_nmos.sym} 170 60 0 0 {name=M1
l=9.9u
w=0.3u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/rhigh.sym} 560 0 0 0 {name=R3
w=0.5e-6
l=65e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13g2_pr/cap_cmim.sym} 560 100 0 0 {name=C1
model=cap_cmim
 w=64.0e-6
 l=64.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/sg13_lv_pmos.sym} 700 10 0 0 {name=M3
l=0.13u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_and2_1.sym} 830 80 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 900 80 0 1 {name=p3 sig_type=std_logic lab=POR_RAW_N
}
C {sg13g2_pr/rhigh.sym} 190 -50 0 0 {name=R4
w=0.5e-6
l=675e-6
model=rhigh
body=VSS
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {lab_pin.sym} 0 0 0 0 {name=lbl_vd sig_type=std_logic lab=VD}
C {lab_pin.sym} 190 10 0 0 {name=lbl_x sig_type=std_logic lab=X}
C {lab_pin.sym} 560 40 0 0 {name=lbl_delay sig_type=std_logic lab=DELAY}
C {lab_pin.sym} 370 10 0 1 {name=lbl_vok sig_type=std_logic lab=VOK}
C {schmitt.sym} 340 10 0 0 {name=x1 VDD=VDD VSS=VSS}
C {sg13g2_buf_1.sym} 410 -60 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 560 140 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 560 -60 0 1 {name=lbl_vok1 sig_type=std_logic lab=VOKB}
