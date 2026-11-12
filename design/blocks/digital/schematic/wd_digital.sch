v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -210 -10 -120 -10 {lab=#net1}
N -210 10 -120 10 {lab=#net2}
N -190 -30 -190 50 {lab=#net3}
N 30 -110 50 -110 {lab=ACTIVE}
N -430 -140 -410 -140 {lab=CLK}
N -430 -120 -410 -120 {lab=WDI_EDGE}
N -130 70 -120 70 {lab=HI}
N -520 10 -510 10 {lab=CLK}
N -210 50 -190 50 {lab=#net3}
N -190 -30 -120 -30 {lab=#net3}
N -210 30 -180 30 {lab=#net4}
N -180 30 -180 50 {lab=#net4}
N -180 50 -120 50 {lab=#net4}
N -130 30 -120 30 {lab=CLK}
N -520 30 -510 30 {lab=#net5}
N -520 30 -520 180 {lab=#net5}
N -520 180 210 180 {lab=#net5}
N 210 -10 210 180 {lab=#net5}
N 180 -10 210 -10 {lab=#net5}
N 30 -140 50 -140 {lab=BOOT}
N 30 -170 50 -170 {lab=RESET}
N 180 -50 190 -50 {lab=ACTIVE}
N 180 -30 190 -30 {lab=BOOT}
N 180 10 220 10 {lab=RESET}
N -130 -50 -120 -50 {lab=WDI_EDGE}
N -430 -100 -410 -100 {lab=POR_B}
N -430 -80 -410 -80 {lab=SET1}
N -430 -60 -410 -60 {lab=SET0}
N -530 50 -510 50 {lab=POR_B}
N -560 -10 -510 -10 {lab=HI}
N -560 -30 -560 -10 {lab=HI}
N -580 -10 -560 -10 {lab=HI}
N -130 90 -120 90 {lab=SET1}
N -130 110 -120 110 {lab=SET0}
N -130 130 -120 130 {lab=POR_B}
C {wd_control.sym} 30 40 0 0 {name=x1 VDD=VDD VSS=VSS}
C {counter17.sym} -360 20 0 0 {name=x2 VDD=VDD VSS=VSS}
C {lab_pin.sym} -580 -10 0 0 {name=p28 sig_type=std_logic lab=HI
}
C {opin.sym} 50 -110 0 0 {name=p40 lab=ACTIVE}
C {lab_pin.sym} 30 -110 0 0 {name=p58 sig_type=std_logic lab=ACTIVE
}
C {lab_pin.sym} -410 -140 0 1 {name=p61 sig_type=std_logic lab=CLK
}
C {ipin.sym} -430 -140 0 0 {name=p62 lab=CLK}
C {lab_pin.sym} -410 -120 0 1 {name=p69 sig_type=std_logic lab=WDI_EDGE
}
C {ipin.sym} -430 -120 0 0 {name=p70 lab=WDI_EDGE}
C {lab_pin.sym} -130 70 0 0 {name=p1 sig_type=std_logic lab=HI
}
C {lab_pin.sym} -520 10 0 0 {name=p2 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} -130 30 0 0 {name=p5 sig_type=std_logic lab=CLK
}
C {lab_pin.sym} 190 -50 0 1 {name=p6 sig_type=std_logic lab=ACTIVE
}
C {opin.sym} 50 -140 0 0 {name=p7 lab=BOOT}
C {lab_pin.sym} 30 -140 0 0 {name=p8 sig_type=std_logic lab=BOOT
}
C {opin.sym} 50 -170 0 0 {name=p9 lab=RESET}
C {lab_pin.sym} 30 -170 0 0 {name=p10 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} 190 -30 0 1 {name=p11 sig_type=std_logic lab=BOOT
}
C {lab_pin.sym} 220 10 0 1 {name=p12 sig_type=std_logic lab=RESET
}
C {lab_pin.sym} -130 -50 0 0 {name=p13 sig_type=std_logic lab=WDI_EDGE
}
C {lab_pin.sym} -410 -100 0 1 {name=p14 sig_type=std_logic lab=POR_B
}
C {ipin.sym} -430 -100 0 0 {name=p15 lab=POR_B}
C {lab_pin.sym} -410 -80 0 1 {name=p16 sig_type=std_logic lab=SET1
}
C {ipin.sym} -430 -80 0 0 {name=p17 lab=SET1}
C {lab_pin.sym} -410 -60 0 1 {name=p18 sig_type=std_logic lab=SET0
}
C {ipin.sym} -430 -60 0 0 {name=p19 lab=SET0}
C {lab_pin.sym} -130 110 0 0 {name=p20 sig_type=std_logic lab=SET0
}
C {lab_pin.sym} -130 90 0 0 {name=p21 sig_type=std_logic lab=SET1
}
C {lab_pin.sym} -130 130 0 0 {name=p22 sig_type=std_logic lab=POR_B
}
C {lab_pin.sym} -530 50 0 0 {name=p23 sig_type=std_logic lab=POR_B
}
C {sg13g2_tiehi.sym} -560 -30 0 0 {name=x3 VDD=VDD VSS=VSS prefix=sg13g2_ }
