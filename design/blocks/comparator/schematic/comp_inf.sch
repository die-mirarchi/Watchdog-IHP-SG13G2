v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 0 -200 20 -200 {lab=OUT}
N 10 -230 30 -230 {lab=VN}
N 10 -260 30 -260 {lab=VP}
N 140 100 180 100 {lab=#net1}
N 260 100 300 100 {lab=#net2}
N 10 -290 30 -290 {lab=VBP}
N 380 100 440 100 {lab=OUT}
N -40 -50 -30 -50 {lab=VBP}
N 10 -90 10 -80 {lab=VDD}
N 0 -130 10 -130 {lab=VDD}
N 10 -20 10 -10 {lab=#net3}
N -110 -10 10 -10 {lab=#net3}
N -110 -10 -110 10 {lab=#net3}
N 10 -10 140 -10 {lab=#net3}
N 140 -10 140 10 {lab=#net3}
N 10 -50 40 -50 {lab=VDD}
N 40 -90 40 -50 {lab=VDD}
N 10 -90 40 -90 {lab=VDD}
N 10 -130 10 -90 {lab=VDD}
N -110 40 -60 40 {lab=VDD}
N 140 40 180 40 {lab=VDD}
N -160 40 -150 40 {lab=VP}
N 80 40 100 40 {lab=VN}
N -110 100 -110 120 {lab=#net4}
N 140 100 140 120 {lab=#net1}
N -150 100 -150 150 {lab=#net4}
N -150 100 -110 100 {lab=#net4}
N -110 70 -110 100 {lab=#net4}
N -110 100 30 100 {lab=#net4}
N 30 100 30 150 {lab=#net4}
N 30 150 100 150 {lab=#net4}
N -110 180 -110 200 {lab=VSS}
N 20 200 140 200 {lab=VSS}
N 140 180 140 200 {lab=VSS}
N 20 200 20 230 {lab=VSS}
N -90 200 20 200 {lab=VSS}
N 140 70 140 100 {lab=#net1}
N -110 150 -90 150 {lab=VSS}
N -90 150 -90 200 {lab=VSS}
N -110 200 -90 200 {lab=VSS}
N 140 150 160 150 {lab=VSS}
N 160 150 160 200 {lab=VSS}
N 140 200 160 200 {lab=VSS}
C {opin.sym} 20 -200 0 0 {name=p6 lab=OUT}
C {lab_pin.sym} 30 -230 0 1 {name=p7 sig_type=std_logic lab=VN
}
C {lab_pin.sym} 0 -200 0 0 {name=p8 sig_type=std_logic lab=OUT
}
C {ipin.sym} 10 -230 0 0 {name=p11 lab=VN}
C {lab_pin.sym} 30 -260 0 1 {name=p14 sig_type=std_logic lab=VP
}
C {ipin.sym} 10 -260 0 0 {name=p15 lab=VP}
C {sg13g2_inv_1.sym} 220 100 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_}
C {sg13g2_inv_1.sym} 340 100 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 30 -290 0 1 {name=p12 sig_type=std_logic lab=VBP
}
C {ipin.sym} 10 -290 0 0 {name=p13 lab=VBP}
C {lab_pin.sym} 440 100 0 1 {name=p16 sig_type=std_logic lab=OUT
}
C {sg13g2_pr/sg13_lv_pmos.sym} -10 -50 0 0 {name=M1
l=1u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} -40 -50 0 0 {name=p17 sig_type=std_logic lab=VBP
}
C {lab_pin.sym} 0 -130 0 0 {name=p18 sig_type=std_logic lab=VDD
}
C {sg13g2_pr/sg13_lv_pmos.sym} -130 40 0 0 {name=M7
l=0.5u
w=40u
ng=5
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} 120 40 0 0 {name=M8
l=0.5u
w=40u
ng=5
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} -60 40 0 1 {name=p19 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} 180 40 0 1 {name=p20 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -160 40 0 0 {name=p21 sig_type=std_logic lab=VP
}
C {lab_pin.sym} 80 40 0 0 {name=p22 sig_type=std_logic lab=VN
}
C {sg13g2_pr/sg13_lv_nmos.sym} -130 150 0 0 {name=M9
l=1u
w=4u
ng=3
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} 120 150 0 0 {name=M10
l=1u
w=4u
ng=3
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 20 230 0 1 {name=p23 sig_type=std_logic lab=VSS}
