v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 160 -50 160 -30 {lab=#net1}
N 160 -30 200 -30 {lab=#net1}
N 380 -30 430 -30 {lab=SYNC}
N 610 -30 630 -30 {lab=#net2}
N 630 -50 630 -30 {lab=#net2}
N 380 -30 380 30 {lab=SYNC}
N 380 30 630 30 {lab=SYNC}
N 630 -10 630 30 {lab=SYNC}
N 380 -130 380 -30 {lab=SYNC}
N 750 -30 790 -30 {lab=EDGE}
N 150 -50 160 -50 {lab=#net1}
N -20 -140 -0 -140 {lab=CLK}
N -20 -170 -0 -170 {lab=N_POR}
C {sg13g2_dfrbpq_2.sym} 60 -30 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_dfrbpq_2.sym} 290 -30 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_and2_2.sym} 690 -30 0 0 {name=x4 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_dfrbp_2.sym} 520 -30 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {opin.sym} 790 -30 0 0 {name=p1 lab=EDGE}
C {opin.sym} 380 -130 0 0 {name=p2 lab=SYNC}
C {lab_pin.sym} 430 -50 0 0 {name=p3 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 200 -50 0 0 {name=p4 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -30 -50 0 0 {name=p5 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -30 -10 0 0 {name=p6 sig_type=std_logic lab=N_POR}
C {lab_pin.sym} 200 -10 0 0 {name=p7 sig_type=std_logic lab=N_POR}
C {lab_pin.sym} 430 -10 0 0 {name=p8 sig_type=std_logic lab=N_POR}
C {ipin.sym} -30 -30 0 0 {name=p9 lab=EN}
C {ipin.sym} -20 -170 0 0 {name=p10 lab=N_POR}
C {lab_pin.sym} 0 -170 0 1 {name=p11 sig_type=std_logic lab=N_POR}
C {lab_pin.sym} 0 -140 0 1 {name=p12 sig_type=std_logic lab=CLK}
C {ipin.sym} -20 -140 0 0 {name=p13 lab=CLK}
