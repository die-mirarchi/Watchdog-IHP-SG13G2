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
N 80 50 210 50 {lab=#net3}
N 80 10 80 50 {lab=#net3}
N 0 -240 20 -240 {lab=VBN}
N 550 50 610 50 {lab=OUT}
N 80 -60 250 -60 {lab=VDD}
N 250 -40 250 -20 {lab=VDD}
N 210 10 210 50 {lab=#net3}
N 20 270 250 270 {lab=VSS}
N 250 260 250 270 {lab=VSS}
N 250 230 260 230 {lab=VSS}
N 260 230 260 270 {lab=VSS}
N 250 270 260 270 {lab=VSS}
N 170 230 210 230 {lab=VBN}
N 250 50 250 200 {lab=#net4}
N 250 50 370 50 {lab=#net4}
N 250 40 250 50 {lab=#net4}
N 250 10 260 10 {lab=VDD}
N 260 -40 260 10 {lab=VDD}
N 250 -40 260 -40 {lab=VDD}
N 250 -60 250 -40 {lab=VDD}
C {sg13g2_pr/sg13_lv_pmos.sym} -90 -20 0 0 {name=M2
l=4u
w=2u
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
l=4u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} -90 120 0 0 {name=M4
l=2u
w=20u
ng=4
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} 60 120 0 0 {name=M5
l=2u
w=20u
ng=4
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} -20 120 0 1 {name=p5 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 130 120 0 1 {name=p9 sig_type=std_logic lab=VSS}
C {sg13g2_pr/sg13_lv_nmos.sym} -20 230 0 0 {name=M6
l=4u
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
C {lab_pin.sym} 20 -240 0 1 {name=p12 sig_type=std_logic lab=VBN
}
C {ipin.sym} 0 -240 0 0 {name=p13 lab=VBN}
C {lab_pin.sym} 610 50 0 1 {name=p16 sig_type=std_logic lab=OUT
}
C {sg13g2_pr/sg13_lv_pmos.sym} 230 10 0 0 {name=M1
l=4u
w=4u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} 230 230 0 0 {name=M7
l=4u
w=2u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} 170 230 0 0 {name=p17 sig_type=std_logic lab=VBN
}
C {schmitt.sym} 520 50 0 0 {name=x1 VDD=VDD VSS=VSS}
