v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -110 -20 -90 -20 {lab=CLK}
N -110 0 -90 0 {lab=VDD}
N -110 20 -90 20 {lab=POR_RAW_N}
N 90 -20 150 -20 {lab=#net1}
N 90 0 110 0 {lab=P1_N}
N 190 -20 210 -20 {lab=CLK}
N 190 20 210 20 {lab=POR_RAW_N}
N 440 -20 520 -20 {lab=SYNC_N}
N 390 0 410 0 {lab=SYNC_N}
N 500 20 520 20 {lab=DONE_N}
N 640 0 660 0 {lab=EN}
N -530 140 -510 140 {lab=C0}
N -850 140 -830 140 {lab=POR_RAW_N}
N -850 160 -830 160 {lab=CLK}
N -850 180 -830 180 {lab=EN}
N -850 200 -830 200 {lab=LO}
N -530 160 -510 160 {lab=D0}
N -530 180 -510 180 {lab=D0_N}
N -70 140 -50 140 {lab=C1}
N -390 160 -370 160 {lab=CLK}
N -390 200 -370 200 {lab=LO}
N -70 160 -50 160 {lab=D1}
N 390 140 410 140 {lab=C2}
N 70 140 90 140 {lab=POR_RAW_N}
N 70 160 90 160 {lab=CLK}
N 70 200 90 200 {lab=LO}
N 390 160 410 160 {lab=D2}
N 830 140 850 140 {lab=C3}
N 510 140 530 140 {lab=POR_RAW_N}
N 510 160 530 160 {lab=CLK}
N 510 200 530 200 {lab=LO}
N 830 160 850 160 {lab=D3}
N 1260 140 1280 140 {lab=C4}
N 940 140 960 140 {lab=POR_RAW_N}
N 940 160 960 160 {lab=CLK}
N 940 200 960 200 {lab=LO}
N 1260 160 1280 160 {lab=D4}
N 1260 180 1280 180 {lab=D4_N}
N -180 350 -160 350 {lab=C4}
N -180 390 -160 390 {lab=POR_B}
N 10 370 80 370 {lab=DN}
N 60 350 80 350 {lab=CLK}
N 60 390 80 390 {lab=POR_RAW_N}
N 260 350 280 350 {lab=POR_B}
N 260 370 280 370 {lab=DONE_N}
N -390 -30 -370 -30 {lab=POR_RAW_N}
N -390 0 -370 0 {lab=CLK}
N -390 30 -370 30 {lab=POR_B}
N 150 -20 150 -0 {lab=#net1}
N 150 -0 210 0 {lab=#net1}
N 110 -40 110 -0 {lab=P1_N}
N -830 250 -830 270 {lab=LO}
N -370 110 -370 140 {lab=POR_RAW_N}
N 10 350 10 370 {lab=DN}
N -40 370 10 370 {lab=DN}
N 940 110 940 140 {lab=POR_RAW_N}
N 850 130 850 140 {lab=C3}
N 890 140 890 180 {lab=C3}
N 850 140 890 140 {lab=C3}
N 890 180 960 180 {lab=C3}
N 830 180 830 200 {lab=D3_N}
N 390 180 390 200 {lab=D2_N}
N 510 100 510 140 {lab=POR_RAW_N}
N 410 130 410 140 {lab=C2}
N 410 140 450 140 {lab=C2}
N 450 140 450 180 {lab=C2}
N 450 180 530 180 {lab=C2}
N 70 100 70 140 {lab=POR_RAW_N}
N -50 120 -50 140 {lab=C1}
N -50 140 20 140 {lab=C1}
N 20 140 20 180 {lab=C1}
N 20 180 90 180 {lab=C1}
N -70 180 -70 190 {lab=D1_N}
N -510 130 -510 140 {lab=C0}
N -510 140 -440 140 {lab=C0}
N -440 140 -440 180 {lab=C0}
N -440 180 -370 180 {lab=C0}
N 280 330 280 350 {lab=POR_B}
N 280 350 370 350 {lab=POR_B}
N 370 350 370 450 {lab=POR_B}
N -180 450 370 450 {lab=POR_B}
N -180 390 -180 450 {lab=POR_B}
N 440 -40 440 -20 {lab=SYNC_N}
N 390 -20 440 -20 {lab=SYNC_N}
C {sg13g2_dfrbp_1.sym} 0 0 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -110 -20 0 0 {name=l0 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -110 0 0 0 {name=l1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -110 20 0 0 {name=l2 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 110 -40 0 1 {name=l4 sig_type=std_logic lab=P1_N}
C {sg13g2_dfrbp_1.sym} 300 0 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 190 -20 0 0 {name=l5 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 190 20 0 0 {name=l7 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 410 0 0 1 {name=l9 sig_type=std_logic lab=SYNC_N}
C {sg13g2_and2_1.sym} 580 0 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 500 20 0 0 {name=l11 sig_type=std_logic lab=DONE_N}
C {lab_pin.sym} 660 0 0 1 {name=l12 sig_type=std_logic lab=EN}
C {one_bit.sym} -680 170 0 0 {name=x4 VDD=VDD VSS=VSS}
C {lab_pin.sym} -510 130 0 1 {name=l13 sig_type=std_logic lab=C0}
C {lab_pin.sym} -850 140 0 0 {name=l14 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} -850 160 0 0 {name=l15 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -850 180 0 0 {name=l16 sig_type=std_logic lab=EN}
C {lab_pin.sym} -850 200 0 0 {name=l17 sig_type=std_logic lab=LO}
C {lab_pin.sym} -510 160 0 1 {name=l18 sig_type=std_logic lab=D0}
C {lab_pin.sym} -510 180 0 1 {name=l19 sig_type=std_logic lab=D0_N}
C {one_bit.sym} -220 170 0 0 {name=x5 VDD=VDD VSS=VSS}
C {lab_pin.sym} -50 120 0 1 {name=l20 sig_type=std_logic lab=C1}
C {lab_pin.sym} -370 110 0 0 {name=l21 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} -390 160 0 0 {name=l22 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -390 200 0 0 {name=l24 sig_type=std_logic lab=LO}
C {lab_pin.sym} -50 160 0 1 {name=l25 sig_type=std_logic lab=D1}
C {lab_pin.sym} -70 190 0 1 {name=l26 sig_type=std_logic lab=D1_N}
C {one_bit.sym} 240 170 0 0 {name=x6 VDD=VDD VSS=VSS}
C {lab_pin.sym} 410 130 0 1 {name=l27 sig_type=std_logic lab=C2}
C {lab_pin.sym} 70 100 0 0 {name=l28 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 70 160 0 0 {name=l29 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 70 200 0 0 {name=l31 sig_type=std_logic lab=LO}
C {lab_pin.sym} 410 160 0 1 {name=l32 sig_type=std_logic lab=D2}
C {lab_pin.sym} 390 200 0 1 {name=l33 sig_type=std_logic lab=D2_N}
C {one_bit.sym} 680 170 0 0 {name=x7 VDD=VDD VSS=VSS}
C {lab_pin.sym} 850 130 0 1 {name=l34 sig_type=std_logic lab=C3}
C {lab_pin.sym} 510 100 0 0 {name=l35 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 510 160 0 0 {name=l36 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 510 200 0 0 {name=l38 sig_type=std_logic lab=LO}
C {lab_pin.sym} 850 160 0 1 {name=l39 sig_type=std_logic lab=D3}
C {lab_pin.sym} 830 200 0 1 {name=l40 sig_type=std_logic lab=D3_N}
C {one_bit.sym} 1110 170 0 0 {name=x8 VDD=VDD VSS=VSS}
C {lab_pin.sym} 1280 140 0 1 {name=l41 sig_type=std_logic lab=C4}
C {lab_pin.sym} 940 110 0 0 {name=l42 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 940 160 0 0 {name=l43 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 940 200 0 0 {name=l45 sig_type=std_logic lab=LO}
C {lab_pin.sym} 1280 160 0 1 {name=l46 sig_type=std_logic lab=D4}
C {lab_pin.sym} 1280 180 0 1 {name=l47 sig_type=std_logic lab=D4_N}
C {sg13g2_or2_1.sym} -100 370 0 0 {name=x9 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -180 350 0 0 {name=l48 sig_type=std_logic lab=C4}
C {sg13g2_dfrbp_1.sym} 170 370 0 0 {name=x10 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 60 350 0 0 {name=l51 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 10 350 0 0 {name=l52 sig_type=std_logic lab=DN}
C {lab_pin.sym} 60 390 0 0 {name=l53 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 280 330 0 1 {name=l54 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 280 370 0 1 {name=l55 sig_type=std_logic lab=DONE_N}
C {sg13g2_tielo.sym} -830 270 0 0 {name=x11 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -830 250 0 1 {name=l56 sig_type=std_logic lab=LO}
C {ipin.sym} -390 -30 0 0 {name=p13 lab=POR_RAW_N}
C {lab_pin.sym} -370 -30 0 1 {name=p12 sig_type=std_logic lab=POR_RAW_N}
C {ipin.sym} -390 0 0 0 {name=p15 lab=CLK}
C {lab_pin.sym} -370 0 0 1 {name=p14 sig_type=std_logic lab=CLK}
C {opin.sym} -370 30 0 0 {name=p5 lab=POR_B}
C {lab_pin.sym} -390 30 0 0 {name=p7 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 440 -40 0 1 {name=l3 sig_type=std_logic lab=SYNC}
