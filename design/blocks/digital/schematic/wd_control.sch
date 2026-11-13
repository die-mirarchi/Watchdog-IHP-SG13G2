v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {Config. autorreparable (13/11/2026)} -420 -55 0 0 0.3 0.3 {}
T {GN = POR_B & RS_N: CFG relee SET1/SET0} -420 -28 0 0 0.22 0.22 {}
T {en el POR y en cada pulso de RESET} -420 -10 0 0 0.22 0.22 {}
T {DIS = CFG0 & SET0 & SET1 & CFG1} 100 135 0 0 0.22 0.22 {}
T {(un error en CFG no deshabilita)} 100 155 0 0 0.22 0.22 {}
T {A3 = T10 (antes LO)} 300 -60 0 0 0.2 0.2 {}
N 40 0 100 0 {lab=CFG0}
N 100 0 140 0 {lab=CFG0}
N 100 0 100 15 {lab=CFG0}
N 140 0 140 -20 {lab=CFG0}
N 140 -20 170 -20 {lab=CFG0}
N 40 90 100 90 {lab=CFG1}
N 100 90 140 90 {lab=CFG1}
N 100 90 100 75 {lab=CFG1}
N 140 90 140 100 {lab=CFG1}
N 140 100 170 100 {lab=CFG1}
N 150 20 170 20 {lab=SET0}
N 150 60 170 60 {lab=SET1}
N 290 40 310 40 {lab=DIS}
N 400 90 410 90 {lab=T10}
N -380 55 -360 55 {lab=POR_B}
N -380 95 -360 95 {lab=RS_N}
N -240 75 -220 75 {lab=GN}
N -160 -70 -140 -70 {lab=POR_B}
N -160 -100 -140 -100 {lab=SET0}
N 0 -100 20 -100 {lab=CLR}
N 0 -70 20 -70 {lab=RESET}
N -160 -130 -140 -130 {lab=SET1}
N -160 -160 -140 -160 {lab=HI}
N -150 0 -140 0 {lab=GN}
N -150 20 -140 20 {lab=SET0}
N -150 40 -140 40 {lab=HI}
N -150 90 -140 90 {lab=GN}
N -150 110 -140 110 {lab=SET1}
N -150 130 -140 130 {lab=HI}
N -150 230 -140 230 {lab=WDI_EDGE}
N 50 270 70 270 {lab=NBA}
N 50 250 50 270 {lab=NBA}
N 20 270 50 270 {lab=NBA}
N 60 310 70 310 {lab=RS_N}
N 270 270 280 270 {lab=CLK}
N 210 290 280 290 {lab=NBD}
N 210 290 210 300 {lab=NBD}
N 190 290 210 290 {lab=NBD}
N 270 310 280 310 {lab=POR_B}
N 460 270 470 270 {lab=NB}
N 460 290 470 290 {lab=BOOT}
N 30 470 50 470 {lab=OR3}
N 130 490 160 490 {lab=#net1}
N -160 -190 -140 -190 {lab=T01}
N -120 470 -110 470 {lab=WDI_EDGE}
N -120 430 -110 430 {lab=DIS}
N 30 470 30 480 {lab=OR3}
N 10 470 30 470 {lab=OR3}
N -120 510 -110 510 {lab=HIT}
N 240 490 250 490 {lab=CLR}
N 390 130 410 130 {lab=CFG0}
N 390 160 410 160 {lab=CFG1}
N 400 50 410 50 {lab=T10}
N 400 10 410 10 {lab=T01}
N 400 -30 410 -30 {lab=T00}
N 490 30 520 30 {lab=TON}
N 510 -10 520 -10 {lab=T10}
N 520 30 520 40 {lab=TON}
N 600 10 630 10 {lab=TO}
N 630 10 630 30 {lab=TO}
N 630 10 740 10 {lab=TO}
N 730 50 740 50 {lab=WE_N}
N 650 50 650 90 {lab=WDI_EDGE}
N 740 50 740 90 {lab=WE_N}
N 730 -60 730 -30 {lab=ACTIVE}
N 730 -30 740 -30 {lab=ACTIVE}
N 40 510 50 510 {lab=T01}
N 40 550 50 550 {lab=RESET}
N 600 -50 610 -50 {lab=RESET}
N 600 -90 610 -90 {lab=DIS}
N 880 10 930 10 {lab=HIT}
N -150 270 -140 270 {lab=ACTIVE}
N -150 310 -140 310 {lab=NB}
N 880 10 880 30 {lab=HIT}
N 860 10 880 10 {lab=HIT}
N 920 -30 930 -30 {lab=Q10_N}
N 920 -70 930 -70 {lab=RESET}
N 1090 -30 1120 -30 {lab=RSD}
N 1120 -50 1120 -30 {lab=RSD}
N 1120 -30 1140 -30 {lab=RSD}
N 1130 -10 1140 -10 {lab=POR_B}
N 1140 -70 1140 -50 {lab=CLK}
N 1320 -50 1330 -50 {lab=RESET}
N 1320 -30 1330 -30 {lab=RS_N}
N 0 -160 20 -160 {lab=ACTIVE}
N 0 -130 20 -130 {lab=BOOT}
N -160 -220 -140 -220 {lab=CLK}
N -160 -250 -140 -250 {lab=T10}
N -160 -280 -140 -280 {lab=T00}
N -160 -310 -140 -310 {lab=Q10_N}
N -160 -340 -140 -340 {lab=WDI_EDGE}
N 730 -60 740 -60 {lab=ACTIVE}
N 730 -70 730 -60 {lab=ACTIVE}
C {sg13g2_dllrq_1.sym} -50 20 0 0 {name=x1 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_dllrq_1.sym} -50 110 0 0 {name=x2 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -140 -70 0 1 {name=p12 sig_type=std_logic lab=POR_B
}
C {ipin.sym} -160 -70 0 0 {name=p13 lab=POR_B}
C {lab_pin.sym} -140 -100 0 1 {name=p92 sig_type=std_logic lab=SET0
}
C {ipin.sym} -160 -100 0 0 {name=p93 lab=SET0}
C {opin.sym} 20 -100 0 0 {name=p102 lab=CLR}
C {lab_pin.sym} 0 -100 0 0 {name=p103 sig_type=std_logic lab=CLR
}
C {opin.sym} 20 -70 0 0 {name=p104 lab=RESET}
C {lab_pin.sym} 0 -70 0 0 {name=p105 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} -140 -130 0 1 {name=p1 sig_type=std_logic lab=SET1
}
C {ipin.sym} -160 -130 0 0 {name=p2 lab=SET1}
C {lab_pin.sym} -140 -160 0 1 {name=p3 sig_type=std_logic lab=HI
}
C {ipin.sym} -160 -160 0 0 {name=p4 lab=HI}
C {lab_pin.sym} -150 0 0 0 {name=p5 sig_type=std_logic lab=GN
}
C {lab_pin.sym} -150 20 0 0 {name=p6 sig_type=std_logic lab=SET0
}
C {lab_pin.sym} -150 40 0 0 {name=p7 sig_type=std_logic lab=HI
}
C {lab_pin.sym} -150 90 0 0 {name=p8 sig_type=std_logic lab=GN
}
C {lab_pin.sym} -150 110 0 0 {name=p9 sig_type=std_logic lab=SET1
}
C {lab_pin.sym} -150 130 0 0 {name=p10 sig_type=std_logic lab=HI
}
C {sg13g2_a21o_1.sym} -60 270 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -150 230 0 0 {name=p16 sig_type=std_logic lab=WDI_EDGE
}
C {lab_pin.sym} -150 270 0 0 {name=p17 sig_type=std_logic lab=ACTIVE
}
C {lab_pin.sym} -150 310 0 0 {name=p18 sig_type=std_logic lab=NB
}
C {lab_pin.sym} 50 250 0 0 {name=p19 sig_type=std_logic lab=NBA
}
C {sg13g2_and2_1.sym} 130 290 0 0 {name=x5 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 60 310 0 0 {name=p20 sig_type=std_logic lab=RS_N
}
C {sg13g2_dfrbp_1.sym} 370 290 0 0 {name=x6 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 270 270 0 0 {name=p21 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} 210 300 0 0 {name=p22 sig_type=std_logic lab=NBD
}
C {lab_pin.sym} 270 310 0 0 {name=p23 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} 470 290 0 1 {name=p24 sig_type=std_logic lab=BOOT
}
C {lab_pin.sym} 470 270 0 1 {name=p25 sig_type=std_logic lab=NB
}
C {sg13g2_or3_1.sym} -50 470 0 0 {name=x7 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_mux2_2.sym} 90 490 0 0 {name=x8 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_buf_2.sym} 200 490 0 0 {name=x9 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 40 510 0 0 {name=p26 sig_type=std_logic lab=T01
}
C {lab_pin.sym} 40 550 0 0 {name=p27 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} -140 -190 0 1 {name=p28 sig_type=std_logic lab=T01
}
C {ipin.sym} -160 -190 0 0 {name=p29 lab=T01}
C {lab_pin.sym} -120 430 0 0 {name=p30 sig_type=std_logic lab=DIS
}
C {lab_pin.sym} -120 510 0 0 {name=p32 sig_type=std_logic lab=HIT
}
C {lab_pin.sym} -120 470 0 0 {name=p33 sig_type=std_logic lab=WDI_EDGE
}
C {lab_pin.sym} 30 480 0 0 {name=p31 sig_type=std_logic lab=OR3
}
C {lab_pin.sym} 250 490 0 1 {name=p34 sig_type=std_logic lab=CLR
}
C {sg13g2_mux4_1.sym} 450 30 0 0 {name=x10 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 390 130 0 0 {name=p35 sig_type=std_logic lab=CFG0
}
C {lab_pin.sym} 390 160 0 0 {name=p36 sig_type=std_logic lab=CFG1
}
C {lab_pin.sym} 400 10 0 0 {name=p37 sig_type=std_logic lab=T01
}
C {lab_pin.sym} 400 -30 0 0 {name=p38 sig_type=std_logic lab=T00
}
C {lab_pin.sym} 400 50 0 0 {name=p39 sig_type=std_logic lab=T10
}
C {sg13g2_mux2_1.sym} 560 10 0 0 {name=x11 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 510 -10 0 0 {name=p41 sig_type=std_logic lab=T10
}
C {lab_pin.sym} 520 70 0 0 {name=p42 sig_type=std_logic lab=NB
}
C {lab_pin.sym} 520 40 0 0 {name=p43 sig_type=std_logic lab=TON
}
C {lab_pin.sym} 630 30 0 0 {name=p44 sig_type=std_logic lab=TO
}
C {sg13g2_and3_2.sym} 800 10 0 0 {name=x12 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {sg13g2_inv_1.sym} 690 50 0 0 {name=x13 VDD=VDD VSS=VSS prefix=sg13g2_}
C {lab_pin.sym} 650 90 0 0 {name=p45 sig_type=std_logic lab=WDI_EDGE
}
C {lab_pin.sym} 740 90 0 0 {name=p46 sig_type=std_logic lab=WE_N
}
C {sg13g2_nor2_2.sym} 670 -70 0 0 {name=x14 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 600 -90 0 0 {name=p47 sig_type=std_logic lab=DIS
}
C {lab_pin.sym} 600 -50 0 0 {name=p48 sig_type=std_logic lab=RESET
}
C {sg13g2_a21o_1.sym} 1010 -30 0 0 {name=x15 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 880 30 0 0 {name=p49 sig_type=std_logic lab=HIT
}
C {lab_pin.sym} 920 -70 0 0 {name=p50 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} 920 -30 0 0 {name=p51 sig_type=std_logic lab=Q10_N
}
C {lab_pin.sym} 1120 -50 0 0 {name=p52 sig_type=std_logic lab=RSD
}
C {sg13g2_dfrbp_2.sym} 1230 -30 0 0 {name=x16 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 1130 -10 0 0 {name=p53 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} 1140 -70 0 0 {name=p54 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} 1330 -50 0 1 {name=p55 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} 1330 -30 0 1 {name=p56 sig_type=std_logic lab=RS_N
}
C {opin.sym} 20 -160 0 0 {name=p40 lab=ACTIVE}
C {lab_pin.sym} 0 -160 0 0 {name=p58 sig_type=std_logic lab=ACTIVE
}
C {opin.sym} 20 -130 0 0 {name=p59 lab=BOOT}
C {lab_pin.sym} 0 -130 0 0 {name=p60 sig_type=std_logic lab=BOOT
}
C {lab_pin.sym} -140 -220 0 1 {name=p61 sig_type=std_logic lab=CLK
}
C {ipin.sym} -160 -220 0 0 {name=p62 lab=CLK}
C {lab_pin.sym} -140 -250 0 1 {name=p63 sig_type=std_logic lab=T10
}
C {ipin.sym} -160 -250 0 0 {name=p64 lab=T10}
C {lab_pin.sym} -140 -280 0 1 {name=p65 sig_type=std_logic lab=T00
}
C {ipin.sym} -160 -280 0 0 {name=p66 lab=T00}
C {lab_pin.sym} -140 -310 0 1 {name=p67 sig_type=std_logic lab=Q10_N
}
C {ipin.sym} -160 -310 0 0 {name=p68 lab=Q10_N}
C {lab_pin.sym} -140 -340 0 1 {name=p69 sig_type=std_logic lab=WDI_EDGE
}
C {ipin.sym} -160 -340 0 0 {name=p70 lab=WDI_EDGE}
C {lab_pin.sym} 740 -60 0 1 {name=p71 sig_type=std_logic lab=ACTIVE
}
C {lab_pin.sym} 100 15 0 0 {name=p80 sig_type=std_logic lab=CFG0
}
C {lab_pin.sym} 100 75 0 0 {name=p81 sig_type=std_logic lab=CFG1
}
C {sg13g2_and4_1.sym} 230 40 0 0 {name=x4 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} 150 20 0 0 {name=p83 sig_type=std_logic lab=SET0
}
C {lab_pin.sym} 150 60 0 0 {name=p84 sig_type=std_logic lab=SET1
}
C {lab_pin.sym} 310 40 0 1 {name=p86 sig_type=std_logic lab=DIS
}
C {lab_pin.sym} 400 90 0 0 {name=p90 sig_type=std_logic lab=T10
}
C {sg13g2_and2_1.sym} -300 75 0 0 {name=x18 VDD=VDD VSS=VSS prefix=sg13g2_ }
C {lab_pin.sym} -380 55 0 0 {name=p87 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} -380 95 0 0 {name=p88 sig_type=std_logic lab=RS_N
}
C {lab_pin.sym} -220 75 0 1 {name=p89 sig_type=std_logic lab=GN
}
