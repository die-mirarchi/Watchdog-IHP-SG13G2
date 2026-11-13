v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {wd_reset_sync v2 (12/11/2026): sincronizador de 2 FF (x1, x2) + retardo de POR de 32 ciclos} -300 -330 0 0 0.4 0.4 {}
T {contador de 5 bits (x4..x8, one_bit) habilitado con EN = SYNC & DONE_N; x10 sube POR_B al llegar a 31 (C4)} -300 -300 0 0 0.3 0.3 {}
T {POR_B sube en el 34.o flanco de CLK tras POR_RAW_N (~3,3 ms); POR_RAW_N = 0 resetea todo asincronicamente} -300 -275 0 0 0.3 0.3 {}
N -110 -20 -90 -20 {lab=CLK}
N -110 0 -90 0 {lab=VDD}
N -110 20 -90 20 {lab=POR_RAW_N}
N 110 -20 90 -20 {lab=P1}
N 110 0 90 0 {lab=P1_N}
N 190 -20 210 -20 {lab=CLK}
N 190 0 210 0 {lab=P1}
N 190 20 210 20 {lab=POR_RAW_N}
N 410 -20 390 -20 {lab=SYNC}
N 410 0 390 0 {lab=SYNC_N}
N 500 -20 520 -20 {lab=SYNC}
N 500 20 520 20 {lab=DONE_N}
N 660 0 640 0 {lab=EN}
N 170 220 150 220 {lab=C0}
N -170 220 -150 220 {lab=POR_RAW_N}
N -170 240 -150 240 {lab=CLK}
N -170 260 -150 260 {lab=EN}
N -170 280 -150 280 {lab=LO}
N 170 240 150 240 {lab=D0}
N 170 260 150 260 {lab=D0_N}
N 550 220 530 220 {lab=C1}
N 210 220 230 220 {lab=POR_RAW_N}
N 210 240 230 240 {lab=CLK}
N 210 260 230 260 {lab=C0}
N 210 280 230 280 {lab=LO}
N 550 240 530 240 {lab=D1}
N 550 260 530 260 {lab=D1_N}
N 930 220 910 220 {lab=C2}
N 590 220 610 220 {lab=POR_RAW_N}
N 590 240 610 240 {lab=CLK}
N 590 260 610 260 {lab=C1}
N 590 280 610 280 {lab=LO}
N 930 240 910 240 {lab=D2}
N 930 260 910 260 {lab=D2_N}
N 1310 220 1290 220 {lab=C3}
N 970 220 990 220 {lab=POR_RAW_N}
N 970 240 990 240 {lab=CLK}
N 970 260 990 260 {lab=C2}
N 970 280 990 280 {lab=LO}
N 1310 240 1290 240 {lab=D3}
N 1310 260 1290 260 {lab=D3_N}
N 1690 220 1670 220 {lab=C4}
N 1350 220 1370 220 {lab=POR_RAW_N}
N 1350 240 1370 240 {lab=CLK}
N 1350 260 1370 260 {lab=C3}
N 1350 280 1370 280 {lab=LO}
N 1690 240 1670 240 {lab=D4}
N 1690 260 1670 260 {lab=D4_N}
N 500 430 520 430 {lab=C4}
N 500 470 520 470 {lab=POR_B}
N 660 450 640 450 {lab=DN}
N 740 430 760 430 {lab=CLK}
N 740 450 760 450 {lab=DN}
N 740 470 760 470 {lab=POR_RAW_N}
N 960 430 940 430 {lab=POR_B}
N 960 450 940 450 {lab=DONE_N}
N 300 450 300 480 {lab=LO}
N -300 -200 -280 -200 {lab=POR_RAW_N}
N -300 -170 -280 -170 {lab=CLK}
N -300 -140 -280 -140 {lab=POR_B}
C {sg13g2_dfrbp_1.sym} 0 0 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -110 -20 0 0 {name=l0 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -110 0 0 0 {name=l1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -110 20 0 0 {name=l2 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 110 -20 0 1 {name=l3 sig_type=std_logic lab=P1}
C {lab_pin.sym} 110 0 0 1 {name=l4 sig_type=std_logic lab=P1_N}
C {sg13g2_dfrbp_1.sym} 300 0 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 190 -20 0 0 {name=l5 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 190 0 0 0 {name=l6 sig_type=std_logic lab=P1}
C {lab_pin.sym} 190 20 0 0 {name=l7 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 410 -20 0 1 {name=l8 sig_type=std_logic lab=SYNC}
C {lab_pin.sym} 410 0 0 1 {name=l9 sig_type=std_logic lab=SYNC_N}
C {sg13g2_and2_1.sym} 580 0 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 500 -20 0 0 {name=l10 sig_type=std_logic lab=SYNC}
C {lab_pin.sym} 500 20 0 0 {name=l11 sig_type=std_logic lab=DONE_N}
C {lab_pin.sym} 660 0 0 1 {name=l12 sig_type=std_logic lab=EN}
C {one_bit.sym} 0 250 0 0 {name=x4 VDD=VDD VSS=VSS}
C {lab_pin.sym} 170 220 0 1 {name=l13 sig_type=std_logic lab=C0}
C {lab_pin.sym} -170 220 0 0 {name=l14 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} -170 240 0 0 {name=l15 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -170 260 0 0 {name=l16 sig_type=std_logic lab=EN}
C {lab_pin.sym} -170 280 0 0 {name=l17 sig_type=std_logic lab=LO}
C {lab_pin.sym} 170 240 0 1 {name=l18 sig_type=std_logic lab=D0}
C {lab_pin.sym} 170 260 0 1 {name=l19 sig_type=std_logic lab=D0_N}
C {one_bit.sym} 380 250 0 0 {name=x5 VDD=VDD VSS=VSS}
C {lab_pin.sym} 550 220 0 1 {name=l20 sig_type=std_logic lab=C1}
C {lab_pin.sym} 210 220 0 0 {name=l21 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 210 240 0 0 {name=l22 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 210 260 0 0 {name=l23 sig_type=std_logic lab=C0}
C {lab_pin.sym} 210 280 0 0 {name=l24 sig_type=std_logic lab=LO}
C {lab_pin.sym} 550 240 0 1 {name=l25 sig_type=std_logic lab=D1}
C {lab_pin.sym} 550 260 0 1 {name=l26 sig_type=std_logic lab=D1_N}
C {one_bit.sym} 760 250 0 0 {name=x6 VDD=VDD VSS=VSS}
C {lab_pin.sym} 930 220 0 1 {name=l27 sig_type=std_logic lab=C2}
C {lab_pin.sym} 590 220 0 0 {name=l28 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 590 240 0 0 {name=l29 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 590 260 0 0 {name=l30 sig_type=std_logic lab=C1}
C {lab_pin.sym} 590 280 0 0 {name=l31 sig_type=std_logic lab=LO}
C {lab_pin.sym} 930 240 0 1 {name=l32 sig_type=std_logic lab=D2}
C {lab_pin.sym} 930 260 0 1 {name=l33 sig_type=std_logic lab=D2_N}
C {one_bit.sym} 1140 250 0 0 {name=x7 VDD=VDD VSS=VSS}
C {lab_pin.sym} 1310 220 0 1 {name=l34 sig_type=std_logic lab=C3}
C {lab_pin.sym} 970 220 0 0 {name=l35 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 970 240 0 0 {name=l36 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 970 260 0 0 {name=l37 sig_type=std_logic lab=C2}
C {lab_pin.sym} 970 280 0 0 {name=l38 sig_type=std_logic lab=LO}
C {lab_pin.sym} 1310 240 0 1 {name=l39 sig_type=std_logic lab=D3}
C {lab_pin.sym} 1310 260 0 1 {name=l40 sig_type=std_logic lab=D3_N}
C {one_bit.sym} 1520 250 0 0 {name=x8 VDD=VDD VSS=VSS}
C {lab_pin.sym} 1690 220 0 1 {name=l41 sig_type=std_logic lab=C4}
C {lab_pin.sym} 1350 220 0 0 {name=l42 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 1350 240 0 0 {name=l43 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 1350 260 0 0 {name=l44 sig_type=std_logic lab=C3}
C {lab_pin.sym} 1350 280 0 0 {name=l45 sig_type=std_logic lab=LO}
C {lab_pin.sym} 1690 240 0 1 {name=l46 sig_type=std_logic lab=D4}
C {lab_pin.sym} 1690 260 0 1 {name=l47 sig_type=std_logic lab=D4_N}
C {sg13g2_or2_1.sym} 580 450 0 0 {name=x9 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 500 430 0 0 {name=l48 sig_type=std_logic lab=C4}
C {lab_pin.sym} 500 470 0 0 {name=l49 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 660 450 0 1 {name=l50 sig_type=std_logic lab=DN}
C {sg13g2_dfrbp_1.sym} 850 450 0 0 {name=x10 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 740 430 0 0 {name=l51 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 740 450 0 0 {name=l52 sig_type=std_logic lab=DN}
C {lab_pin.sym} 740 470 0 0 {name=l53 sig_type=std_logic lab=POR_RAW_N}
C {lab_pin.sym} 960 430 0 1 {name=l54 sig_type=std_logic lab=POR_B}
C {lab_pin.sym} 960 450 0 1 {name=l55 sig_type=std_logic lab=DONE_N}
C {sg13g2_tielo.sym} 300 450 0 0 {name=x11 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 300 480 0 1 {name=l56 sig_type=std_logic lab=LO}
C {ipin.sym} -300 -200 0 0 {name=p13 lab=POR_RAW_N}
C {lab_pin.sym} -280 -200 0 1 {name=p12 sig_type=std_logic lab=POR_RAW_N}
C {ipin.sym} -300 -170 0 0 {name=p15 lab=CLK}
C {lab_pin.sym} -280 -170 0 1 {name=p14 sig_type=std_logic lab=CLK}
C {opin.sym} -280 -140 0 0 {name=p5 lab=POR_B}
C {lab_pin.sym} -300 -140 0 0 {name=p7 sig_type=std_logic lab=POR_B}
