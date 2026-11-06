v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 40 -190 60 -190 {lab=OUT}
N -90 0 -90 10 {lab=OUT}
N -90 -90 -90 -80 {lab=P_MID}
N -130 -130 -130 140 {lab=IN}
N -90 0 60 0 {lab=OUT}
N -90 -20 -90 0 {lab=OUT}
N -90 -90 130 -90 {lab=P_MID}
N -90 -100 -90 -90 {lab=P_MID}
N 60 -50 90 -50 {lab=OUT}
N -90 100 -90 110 {lab=N_MID}
N -90 100 130 100 {lab=N_MID}
N -90 70 -90 100 {lab=N_MID}
N 60 70 90 70 {lab=OUT}
N 60 0 60 70 {lab=OUT}
N 130 -90 130 -80 {lab=P_MID}
N 60 -50 60 0 {lab=OUT}
N 120 -20 130 -20 {lab=VSS}
N 130 30 130 40 {lab=VDD}
N 60 0 240 0 {lab=OUT}
N -90 -170 -90 -160 {lab=VDD}
N -90 180 -90 190 {lab=VSS}
N 50 -230 70 -230 {lab=IN}
N -90 -50 -70 -50 {lab=VDD}
N -70 -130 -70 -50 {lab=VDD}
N -90 -170 -70 -170 {lab=VDD}
N -90 -180 -90 -170 {lab=VDD}
N -90 -130 -70 -130 {lab=VDD}
N -70 -170 -70 -130 {lab=VDD}
N -90 40 -70 40 {lab=VSS}
N -70 140 -70 180 {lab=VSS}
N -90 180 -70 180 {lab=VSS}
N -90 170 -90 180 {lab=VSS}
N -90 140 -70 140 {lab=VSS}
N -70 40 -70 140 {lab=VSS}
N 130 70 180 70 {lab=VSS}
N 130 -50 190 -50 {lab=VDD}
C {opin.sym} 60 -190 0 0 {name=p5 lab=OUT}
C {lab_pin.sym} 40 -190 0 0 {name=p7 sig_type=std_logic lab=OUT}
C {sg13g2_pr/sg13_lv_pmos.sym} -110 -130 0 0 {name=M4
l=0.13u
w=1.04u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} -110 40 0 0 {name=M6
l=0.13u
w=0.76u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} -110 -50 0 0 {name=M5
l=0.13u
w=1.04u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} -110 140 0 0 {name=M7
l=0.13u
w=0.76u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos.sym} 110 -50 0 0 {name=M8
l=0.13u
w=0.42u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_nmos.sym} 110 70 0 0 {name=M9
l=0.13u
w=0.42u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_pin.sym} -90 -180 0 0 {name=p9 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} 130 30 0 0 {name=p10 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -90 190 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 120 -20 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 240 0 0 1 {name=p1 sig_type=std_logic lab=OUT}
C {lab_pin.sym} 70 -230 0 1 {name=p2 sig_type=std_logic lab=IN
}
C {ipin.sym} 50 -230 0 0 {name=p13 lab=IN}
C {lab_pin.sym} -130 0 0 0 {name=p3 sig_type=std_logic lab=IN}
C {lab_pin.sym} 180 70 0 1 {name=p4 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 190 -50 0 1 {name=p6 sig_type=std_logic lab=VDD
}
C {lab_pin.sym} -90 -90 0 0 {name=lbl_p_mid sig_type=std_logic lab=P_MID}
C {lab_pin.sym} -90 100 0 0 {name=lbl_n_mid sig_type=std_logic lab=N_MID}
