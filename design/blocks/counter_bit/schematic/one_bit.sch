v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 70 -190 90 -190 {lab=CO}
N -90 -160 -70 -160 {lab=CLK}
N -90 -190 -70 -190 {lab=POR_B}
N 20 -20 30 -20 {lab=CLK}
N 20 20 30 20 {lab=POR_B}
N -20 -0 30 0 {lab=D}
N -180 -20 -160 -20 {lab=INC}
N -220 70 -160 70 {lab=NCLR}
N -160 20 -160 70 {lab=NCLR}
N -90 -100 -70 -100 {lab=CLR}
N -90 -130 -70 -130 {lab=CI}
N 210 0 220 0 {lab=Q_N}
N 210 -20 220 -20 {lab=Q}
N -310 -70 -310 -40 {lab=Q}
N -310 -70 210 -70 {lab=Q}
N 210 -70 210 -20 {lab=Q}
N -320 0 -310 0 {lab=CI}
N -320 70 -300 70 {lab=CLR}
N -180 -40 -180 -20 {lab=INC}
N -190 -20 -180 -20 {lab=INC}
N 20 -50 20 -20 {lab=CLK}
N -20 -20 -20 -0 {lab=D}
N -40 0 -20 -0 {lab=D}
N -340 -100 -340 -70 {lab=Q}
N -340 -70 -310 -70 {lab=Q}
N -360 -140 -340 -140 {lab=CI}
N -360 -140 -360 -10 {lab=CI}
N -360 -10 -310 -10 {lab=CI}
N -310 -10 -310 -0 {lab=CI}
N -220 -120 -210 -120 {lab=CO}
N 70 -160 90 -160 {lab=CO}
N 70 -130 90 -130 {lab=CO}
C {sg13g2_dfrbp_1.sym} 120 0 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {opin.sym} 90 -190 0 0 {name=p5 lab=CO}
C {lab_pin.sym} 70 -190 0 0 {name=p7 sig_type=std_logic lab=CO
}
C {lab_pin.sym} -70 -160 0 1 {name=p14 sig_type=std_logic lab=CLK}
C {ipin.sym} -90 -160 0 0 {name=p15 lab=CLK}
C {lab_pin.sym} -70 -190 0 1 {name=p12 sig_type=std_logic lab=POR_B
}
C {ipin.sym} -90 -190 0 0 {name=p13 lab=POR_B
}
C {lab_pin.sym} 20 20 0 0 {name=p1 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} 20 -50 0 0 {name=p2 sig_type=std_logic lab=CLK
}
C {sg13g2_and2_1.sym} -100 0 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_xor2_1.sym} -250 -20 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_inv_1.sym} -260 70 0 0 {name=x4 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} -70 -100 0 1 {name=p3 sig_type=std_logic lab=CLR}
C {ipin.sym} -90 -100 0 0 {name=p4 lab=CLR}
C {lab_pin.sym} -70 -130 0 1 {name=p6 sig_type=std_logic lab=CI
}
C {ipin.sym} -90 -130 0 0 {name=p8 lab=CI
}
C {lab_pin.sym} 220 -20 0 1 {name=p9 sig_type=std_logic lab=Q
}
C {lab_pin.sym} 220 0 0 1 {name=p10 sig_type=std_logic lab=Q_N
}
C {lab_pin.sym} -320 0 0 0 {name=p11 sig_type=std_logic lab=CI
}
C {lab_pin.sym} -320 70 0 0 {name=p16 sig_type=std_logic lab=CLR
}
C {lab_pin.sym} -160 70 0 1 {name=p17 sig_type=std_logic lab=NCLR
}
C {lab_pin.sym} -180 -40 0 1 {name=p18 sig_type=std_logic lab=INC
}
C {lab_pin.sym} -20 -20 0 1 {name=p19 sig_type=std_logic lab=D
}
C {sg13g2_and2_1.sym} -280 -120 0 0 {name=x5 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -210 -120 0 1 {name=p20 sig_type=std_logic lab=CO
}
C {opin.sym} 90 -160 0 0 {name=p21 lab=Q}
C {lab_pin.sym} 70 -160 0 0 {name=p22 sig_type=std_logic lab=Q
}
C {opin.sym} 90 -130 0 0 {name=p23 lab=Q_N}
C {lab_pin.sym} 70 -130 0 0 {name=p24 sig_type=std_logic lab=Q_N
}
