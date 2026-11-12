v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 270 -30 280 -30 {lab=CLK}
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
N 280 170 300 170 {lab=RESET}
N 280 140 280 170 {lab=RESET}
N 270 170 280 170 {lab=RESET}
N 290 130 300 130 {lab=POR_B}
N 290 70 290 130 {lab=POR_B}
N 270 70 290 70 {lab=POR_B}
N 270 50 270 70 {lab=POR_B}
N 420 150 430 150 {lab=RESET_OUT}
N -400 210 -390 210 {lab=WDI_IN}
N -40 230 -30 230 {lab=SET1}
N -40 250 -30 250 {lab=SET0}
C {wd_oscillater.sym} 120 -30 0 0 {name=x1 VDD=VDD VSS=VSS}
C {wd_reset_sync.sym} 120 60 0 0 {name=x2 VDD=VDD VSS=VSS}
C {wd_por.sym} -200 50 0 0 {name=x3 VDD=VDD VSS=VSS}
C {WDI_INPUT.sym} -240 190 0 0 {name=x4}
C {wd_digital.sym} 120 210 0 0 {name=x5 VDD=VDD VSS=VSS}
C {lab_pin.sym} 280 -30 0 1 {name=l1 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -50 70 0 0 {name=l2 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 290 70 0 1 {name=l3 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} -40 20 0 1 {name=l4 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} -400 190 0 0 {name=l5 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -400 170 0 0 {name=l6 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} -40 170 0 0 {name=l7 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -40 210 0 0 {name=l8 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 280 140 0 0 {name=l9 sig_type=std_logic lab=RESET}
C {lab_pin.sym} 280 190 0 1 {name=l10 sig_type=std_logic lab=BOOT}
C {lab_pin.sym} 280 210 0 1 {name=l11 sig_type=std_logic lab=ACTIVE}
C {sg13g2_and2_2.sym} 360 150 0 0 {name=x6 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 430 150 0 1 {name=l12 sig_type=std_logic lab=RESET_OUT}
C {lab_pin.sym} -400 210 0 0 {name=l13 sig_type=std_logic lab=WDI_IN}
C {lab_pin.sym} -40 230 0 0 {name=l16 sig_type=std_logic lab=SET1}
C {lab_pin.sym} -40 250 0 0 {name=l17 sig_type=std_logic lab=SET0}
