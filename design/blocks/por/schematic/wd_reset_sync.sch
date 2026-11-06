v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 90 -20 120 -20 {lab=P1}
N 120 -20 120 -0 {lab=P1}
N 120 -0 160 -0 {lab=P1}
N 160 20 160 40 {lab=POR_RAW_N}
N -90 40 160 40 {lab=POR_RAW_N}
N -90 20 -90 40 {lab=POR_RAW_N}
N -90 -40 -90 -20 {lab=CLK}
N -90 -40 160 -40 {lab=CLK}
N 160 -40 160 -20 {lab=CLK}
N 10 -80 30 -80 {lab=POR_B}
N 340 -20 350 -20 {lab=POR_B}
N 10 -110 30 -110 {lab=CLK}
N 10 -140 30 -140 {lab=POR_RAW_N}
N -100 -0 -90 -0 {lab=VDD}
C {sg13g2_dfrbp_1.sym} 0 0 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_dfrbp_1.sym} 250 0 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -100 0 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {opin.sym} 30 -80 0 0 {name=p5 lab=POR_B}
C {lab_pin.sym} 10 -80 0 0 {name=p7 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} 350 -20 0 1 {name=p2 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} 30 -110 0 1 {name=p14 sig_type=std_logic lab=CLK}
C {ipin.sym} 10 -110 0 0 {name=p15 lab=CLK}
C {lab_pin.sym} 30 -140 0 1 {name=p12 sig_type=std_logic lab=POR_RAW_N
}
C {ipin.sym} 10 -140 0 0 {name=p13 lab=POR_RAW_N}
C {lab_pin.sym} -90 -40 0 0 {name=p3 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} -90 40 0 0 {name=p4 sig_type=std_logic lab=POR_RAW_N
}
C {lab_pin.sym} 120 -20 0 0 {name=lbl_p1 sig_type=std_logic lab=P1}
C {lab_pin.sym} 90 0 0 1 {name=lbl_p1_n sig_type=std_logic lab=P1_N}
C {lab_pin.sym} 340 0 0 1 {name=lbl_por_b_n sig_type=std_logic lab=POR_B_N}
