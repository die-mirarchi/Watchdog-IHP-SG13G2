v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -70 30 -70 90 {lab=#net1}
N -70 -60 -70 -50 {lab=VDD}
N -110 -20 -110 30 {lab=#net1}
N -110 30 -70 30 {lab=#net1}
N -70 10 -70 30 {lab=#net1}
N -70 -20 -60 -20 {lab=VDD}
N -60 -50 -60 -20 {lab=VDD}
N -70 -50 -60 -50 {lab=VDD}
N -10 -150 10 -150 {lab=OUT}
N 0 -180 20 -180 {lab=VN}
N 0 -210 20 -210 {lab=VP}
N 80 -60 80 -50 {lab=VDD}
N 40 -20 40 30 {lab=#net1}
N 80 -20 90 -20 {lab=VDD}
N 90 -50 90 -20 {lab=VDD}
N 80 -50 90 -50 {lab=VDD}
N -70 30 40 30 {lab=#net1}
N 0 -60 80 -60 {lab=VDD}
N -70 120 -20 120 {lab=VSS}
N 80 120 130 120 {lab=VSS}
N -70 150 -70 160 {lab=#net2}
N 80 150 80 160 {lab=#net2}
N 0 160 80 160 {lab=#net2}
N 80 50 80 90 {lab=#net3}
N 0 160 0 200 {lab=#net2}
N -70 160 0 160 {lab=#net2}
N -80 230 -40 230 {lab=VBN}
N 0 230 20 230 {lab=VSS}
N 20 230 20 270 {lab=VSS}
N 0 270 20 270 {lab=VSS}
N 0 260 0 270 {lab=VSS}
N 0 270 0 300 {lab=VSS}
N -130 120 -110 120 {lab=VP}
N 30 90 40 90 {lab=VN}
N 40 90 40 120 {lab=VN}
N 0 -100 0 -60 {lab=VDD}
N -70 -60 0 -60 {lab=VDD}
N 80 50 120 50 {lab=#net3}
N 80 10 80 50 {lab=#net3}
N 200 50 240 50 {lab=#net4}
N 0 -240 20 -240 {lab=VBN}
N 320 50 380 50 {lab=OUT}
C {sg13g2_pr/sg13_lv_pmos.sym} -90 -20 0 0 {name=M2
l=1u
w=8u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_pin.sym} 0 -100 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -80 230 0 0 {name=p3 sig_type=std_logic lab=VBN
}
C {opin.sym} 10 -150 0 0 {name=p6 lab=OUT}
C {lab_pin.sym} 20 -180 0 1 {name=p7 sig_type=std_logic lab=VN
}
C {lab_pin.sym} -10 -150 0 0 {name=p8 sig_type=std_logic lab=OUT
}
C {ipin.sym} 0 -180 0 0 {name=p11 lab=VN}
C {lab_pin.sym} 20 -210 0 1 {name=p14 sig_type=std_logic lab=VP
}
C {ipin.sym} 0 -210 0 0 {name=p15 lab=VP}
C {sg13g2_pr/sg13_lv_pmos.sym} 60 -20 0 0 {name=M3
l=1u
w=8u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} -90 120 0 0 {name=M4
l=0.5u
w=20u
ng=3
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} 60 120 0 0 {name=M5
l=0.5u
w=20u
ng=3
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} -20 120 0 1 {name=p5 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 130 120 0 1 {name=p9 sig_type=std_logic lab=VSS}
C {sg13g2_pr/sg13_lv_nmos.sym} -20 230 0 0 {name=M6
l=1u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 0 300 0 1 {name=p10 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -130 120 0 0 {name=p2 sig_type=std_logic lab=VP
}
C {lab_pin.sym} 30 90 0 0 {name=p4 sig_type=std_logic lab=VN
}
C {sg13g2_inv_1.sym} 160 50 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_}
C {sg13g2_inv_1.sym} 280 50 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 20 -240 0 1 {name=p12 sig_type=std_logic lab=VBN
}
C {ipin.sym} 0 -240 0 0 {name=p13 lab=VBN}
C {lab_pin.sym} 380 50 0 1 {name=p16 sig_type=std_logic lab=OUT
}
