v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 120 -150 140 -150 {lab=POR_RAW_N}
N -20 -80 490 -80 {lab=VDD}
N 0 0 0 20 {lab=#net1}
N -20 90 0 90 {lab=VSS}
N 0 0 110 0 {lab=#net1}
N 0 -20 0 0 {lab=#net1}
N 110 -0 110 60 {lab=#net1}
N 110 60 150 60 {lab=#net1}
N 200 90 370 90 {lab=VSS}
N -0 80 0 90 {lab=VSS}
N 0 90 200 90 {lab=VSS}
N 190 10 250 10 {lab=#net2}
N 190 10 190 30 {lab=#net2}
N 370 -0 370 20 {lab=#net3}
N 370 80 370 90 {lab=VSS}
N 490 -80 530 -80 {lab=VDD}
N 530 -80 530 -70 {lab=VDD}
N 490 -80 490 -40 {lab=VDD}
N 370 -0 530 -0 {lab=#net3}
N 370 -20 370 -0 {lab=#net3}
N 530 -10 530 -0 {lab=#net3}
N 530 10 580 10 {lab=#net3}
N 530 0 530 10 {lab=#net3}
N 330 10 510 10 {lab=#net4}
N 510 10 510 50 {lab=#net4}
N 510 50 580 50 {lab=#net4}
N 700 30 710 30 {lab=POR_RAW_N}
N 530 -40 540 -40 {lab=VDD}
N 540 -80 540 -40 {lab=VDD}
N 530 -80 540 -80 {lab=VDD}
N 190 60 200 60 {lab=VSS}
N 200 60 200 90 {lab=VSS}
N 190 -20 190 10 {lab=#net2}
C {sg13g2_pr/rhigh.sym} 0 -50 0 0 {name=R1
w=0.5e-6
l=360e-6
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
C {sg13g2_inv_1.sym} 290 10 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_}
C {sg13g2_pr/rhigh.sym} 370 -50 0 0 {name=R3
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
C {sg13g2_pr/cap_cmim.sym} 370 50 0 0 {name=C1
model=cap_cmim
 w=64.0e-6
 l=64.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/sg13_lv_pmos.sym} 510 -40 0 0 {name=M3
l=0.13u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_and2_1.sym} 640 30 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 710 30 0 1 {name=p3 sig_type=std_logic lab=POR_RAW_N
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
