v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {wd_clkmon: si CLK se detiene (o no arranca) CLK_LOST = 1} 380 -110 0 0 0.25 0.25 {}
T {RESET_OUT = RESET + CLK_LOST (fuera de POR_B): sin reloj el uC queda en reset} 560 230 0 0 0.25 0.25 {}
N 270 -30 320 -30 {lab=CLK}
N 320 -30 370 -30 {lab=CLK}
N 320 -30 320 -10 {lab=CLK}
N 670 -30 680 -30 {lab=CLK_LOST}
N 680 -30 680 40 {lab=CLK_LOST}
N 680 40 680 130 {lab=CLK_LOST}
N 680 130 700 130 {lab=CLK_LOST}
N 270 170 310 170 {lab=RESET}
N 310 170 700 170 {lab=RESET}
N 310 170 310 150 {lab=RESET}
N 820 150 840 150 {lab=RESET_OUT}
N -50 70 -30 70 {lab=CLK}
N -40 50 -30 50 {lab=POR_RAW_N}
N -50 50 -40 50 {lab=POR_RAW_N}
N -40 20 -40 50 {lab=POR_RAW_N}
N -400 190 -390 190 {lab=CLK}
N -400 170 -390 170 {lab=POR_B}
N -90 170 -90 190 {lab=#net1}
N -90 190 -30 190 {lab=#net1}
N -40 170 -30 170 {lab=CLK}
N -40 210 -30 210 {lab=POR_B}
N 270 190 280 190 {lab=BOOT}
N 270 210 280 210 {lab=ACTIVE}
N 270 70 290 70 {lab=POR_B}
N 270 50 270 70 {lab=POR_B}
N -400 210 -390 210 {lab=WDI_IN}
N -40 230 -30 230 {lab=SET1}
N -40 250 -30 250 {lab=SET0}
N -50 -150 -30 -150 {lab=SET1}
N -50 -120 -30 -120 {lab=SET0}
N -50 -180 -30 -180 {lab=WDI_IN}
N 170 -180 190 -180 {lab=RESET_OUT}
N -50 -90 -30 -90 {lab=VDD}
N -50 -60 -30 -60 {lab=VSS}
C {wd_oscillater.sym} 120 -30 0 0 {name=x1 VDD=VDD VSS=VSS}
C {wd_reset_sync.sym} 120 60 0 0 {name=x2 VDD=VDD VSS=VSS}
C {wd_por.sym} -200 50 0 0 {name=x3 VDD=VDD VSS=VSS}
C {WDI_INPUT.sym} -240 190 0 0 {name=x4 VDD=VDD VSS=VSS}
C {wd_digital.sym} 120 210 0 0 {name=x5 VDD=VDD VSS=VSS}
C {lab_pin.sym} -50 70 0 0 {name=l2 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 290 70 0 1 {name=l3 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} -40 20 0 1 {name=l4 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} -400 190 0 0 {name=l5 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -400 170 0 0 {name=l6 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} -40 170 0 0 {name=l7 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -40 210 0 0 {name=l8 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 280 190 0 1 {name=l10 sig_type=std_logic lab=BOOT}
C {lab_pin.sym} 280 210 0 1 {name=l11 sig_type=std_logic lab=ACTIVE}
C {lab_pin.sym} -400 210 0 0 {name=l13 sig_type=std_logic lab=WDI_IN}
C {lab_pin.sym} -40 230 0 0 {name=l16 sig_type=std_logic lab=SET1}
C {lab_pin.sym} -40 250 0 0 {name=l17 sig_type=std_logic lab=SET0}
C {lab_pin.sym} -30 -150 0 1 {name=p12 sig_type=std_logic lab=SET1
}
C {ipin.sym} -50 -150 0 0 {name=p13 lab=SET1}
C {lab_pin.sym} -30 -120 0 1 {name=p1 sig_type=std_logic lab=SET0
}
C {ipin.sym} -50 -120 0 0 {name=p2 lab=SET0}
C {lab_pin.sym} -30 -180 0 1 {name=p92 sig_type=std_logic lab=WDI_IN
}
C {ipin.sym} -50 -180 0 0 {name=p93 lab=WDI_IN}
C {opin.sym} 190 -180 0 0 {name=p102 lab=RESET_OUT}
C {iopin.sym} -50 -90 0 1 {name=p3 lab=VDD}
C {lab_pin.sym} -30 -90 0 1 {name=p4 sig_type=std_logic lab=VDD}
C {iopin.sym} -50 -60 0 1 {name=p5 lab=VSS}
C {lab_pin.sym} -30 -60 0 1 {name=p6 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 170 -180 0 0 {name=p103 sig_type=std_logic lab=RESET_OUT
}
C {lab_pin.sym} 320 -10 0 1 {name=l1 sig_type=std_logic lab=CLK}
C {wd_clkmon.sym} 520 -30 0 0 {name=x6 VDD=VDD VSS=VSS}
C {lab_pin.sym} 680 40 0 1 {name=l18 sig_type=std_logic lab=CLK_LOST}
C {sg13g2_or2_1.sym} 760 150 0 0 {name=x7 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 310 150 0 1 {name=l9 sig_type=std_logic lab=RESET}
C {lab_pin.sym} 840 150 0 1 {name=l19 sig_type=std_logic lab=RESET_OUT}
