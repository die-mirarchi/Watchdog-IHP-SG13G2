v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 380 0 380 20 {lab=VBP}
N 250 -90 380 -90 {lab=VDD}
N 380 -90 380 -80 {lab=VDD}
N 60 -0 60 20 {lab=VBN}
N 60 -90 60 -80 {lab=VDD}
N 30 -90 60 -90 {lab=VDD}
N 60 110 380 110 {lab=VSS}
N 380 80 380 110 {lab=VSS}
N 60 80 60 110 {lab=VSS}
N 30 110 60 110 {lab=VSS}
N 340 -50 340 0 {lab=VBP}
N 340 0 380 0 {lab=VBP}
N 380 -20 380 0 {lab=VBP}
N 20 -0 20 50 {lab=VBN}
N 20 -0 60 -0 {lab=VBN}
N 60 -20 60 -0 {lab=VBN}
N 250 -90 250 -60 {lab=VDD}
N 60 -90 250 -90 {lab=VDD}
N 250 -0 340 -0 {lab=VBP}
N 60 50 70 50 {lab=VSS}
N 70 50 70 80 {lab=VSS}
N 60 80 70 80 {lab=VSS}
N 380 -50 390 -50 {lab=VDD}
N 390 -80 390 -50 {lab=VDD}
N 380 -80 390 -80 {lab=VDD}
N 60 0 150 0 {lab=VBN}
N 150 0 150 50 {lab=VBN}
N 80 -130 100 -130 {lab=VBN}
N 80 -160 100 -160 {lab=VBP}
C {sg13g2_pr/sg13_lv_nmos.sym} 40 50 0 0 {name=M1
l=1u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} 360 -50 0 0 {name=M2
l=1u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/rhigh.sym} 380 50 0 0 {name=R2
w=0.5e-6
l=10.0e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13g2_pr/rhigh.sym} 60 -50 0 0 {name=R1
w=0.5e-6
l=10.0e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {lab_pin.sym} 30 -90 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} 30 110 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 20 0 0 0 {name=p3 sig_type=std_logic lab=VBN
}
C {lab_pin.sym} 250 0 0 0 {name=p4 sig_type=std_logic lab=VBP
}
C {sg13g2_pr/cap_cmim.sym} 150 80 0 0 {name=C1
model=cap_cmim
 w=26.0e-6
 l=26.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {sg13g2_pr/cap_cmim.sym} 250 -30 0 0 {name=C2
model=cap_cmim
 w=26.0e-6
 l=26.0e-6
 m=1
  mm_ok=1
 spiceprefix=X}
C {opin.sym} 100 -160 0 0 {name=p5 lab=VBP}
C {opin.sym} 100 -130 0 0 {name=p6 lab=VBN}
C {lab_pin.sym} 80 -160 0 0 {name=p7 sig_type=std_logic lab=VBP
}
C {lab_pin.sym} 80 -130 0 0 {name=p8 sig_type=std_logic lab=VBN
}
