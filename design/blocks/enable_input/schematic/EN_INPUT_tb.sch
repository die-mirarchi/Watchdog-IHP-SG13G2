v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 1550 -510 2450 -300 {flags=graph
y1=-0.1
y2=1.4
ypos1=0
ypos2=2
divy=3
subdivy=1
unity=1
x1=0
x2=0.002
divx=6
subdivx=1
node="clk
en"
color="4 7"
dataset=-1
unitx=0.001
logx=0
logy=0
sim_type=tran
autoload=1
rawfile=/workspace/design/blocks/input/schematic/simulation/EN_INPUT_tb.raw}
B 2 1550 -270 2450 -60 {flags=graph
y1=-0.1
y2=1.4
ypos1=0
ypos2=2
divy=3
subdivy=1
unity=1
x1=0
x2=0.002
divx=6
subdivx=1
node="sync
edge"
color="4 7"
dataset=-1
unitx=0.001
logx=0
logy=0
sim_type=tran
autoload=1
rawfile=/workspace/design/blocks/input/schematic/simulation/EN_INPUT_tb.raw}
B 2 1550 -30 2450 180 {flags=graph
y1=-0.1
y2=1.4
ypos1=0
ypos2=2
divy=3
subdivy=1
unity=1
x1=0
x2=0.002
divx=6
subdivx=1
node="n_por"
color="4 7"
dataset=-1
unitx=0.001
logx=0
logy=0
sim_type=tran
autoload=1
rawfile=/workspace/design/blocks/input/schematic/simulation/EN_INPUT_tb.raw}
T {EN_INPUT - banco de prueba / IHP SG13G2 / TT / 27 C} 40 -590 0 0 0.4 0.4 {}
T {CLK = 10 kHz | EN: flancos en 225 us y 2225 us | EDGE esperado: 100 us} 40 -550 0 0 0.25 0.25 {}
N 450 -320 500 -320 {lab=N_POR}
N 450 -300 500 -300 {lab=CLK}
N 450 -280 500 -280 {lab=EN}
N 800 -320 860 -320 {lab=SYNC}
N 800 -300 860 -300 {lab=EDGE}
N 100 -160 100 -130 {lab=VDD}
N 100 -70 100 -40 {lab=GND}
N 350 -160 350 -130 {lab=CLK}
N 350 -70 350 -40 {lab=GND}
N 700 -160 700 -130 {lab=N_POR}
N 700 -70 700 -40 {lab=GND}
N 1050 -160 1050 -130 {lab=EN}
N 1050 -70 1050 -40 {lab=GND}
C {EN_INPUT.sym} 650 -300 0 0 {name=x1}
C {devices/lab_pin.sym} 450 -320 0 0 {name=l_N_POR lab=N_POR}
C {devices/lab_pin.sym} 450 -300 0 0 {name=l_CLK lab=CLK}
C {devices/lab_pin.sym} 450 -280 0 0 {name=l_EN lab=EN}
C {devices/lab_pin.sym} 860 -320 0 1 {name=l_SYNC lab=SYNC}
C {devices/lab_pin.sym} 860 -300 0 1 {name=l_EDGE lab=EDGE}
C {devices/vsource.sym} 100 -100 0 0 {name=V_VDD value="1.2"}
C {devices/lab_pin.sym} 100 -160 0 0 {name=src_VDD lab=VDD}
C {devices/gnd.sym} 100 -40 0 0 {name=g_VDD lab=GND}
C {devices/vsource.sym} 350 -100 0 0 {name=V_CLK value="PULSE(0 1.2 50u 1n 1n 50u 100u)"}
C {devices/lab_pin.sym} 350 -160 0 0 {name=src_CLK lab=CLK}
C {devices/gnd.sym} 350 -40 0 0 {name=g_CLK lab=GND}
C {devices/vsource.sym} 700 -100 0 0 {name=V_N_POR value="PWL(0 0 20u 0 20.01u 1.2)"}
C {devices/lab_pin.sym} 700 -160 0 0 {name=src_N_POR lab=N_POR}
C {devices/gnd.sym} 700 -40 0 0 {name=g_N_POR lab=GND}
C {devices/vsource.sym} 1050 -100 0 0 {name=V_EN value="PULSE(0 1.2 225u 1n 1n 500u 1m)"}
C {devices/lab_pin.sym} 1050 -160 0 0 {name=src_EN lab=EN}
C {devices/gnd.sym} 1050 -40 0 0 {name=g_EN lab=GND}
C {devices/vsource.sym} 100 -310 0 0 {name=V_VSS value=0}
C {devices/lab_pin.sym} 100 -340 0 0 {name=l_VSS lab=VSS}
C {devices/gnd.sym} 100 -280 0 0 {name=g_VSS lab=GND}
C {devices/code_shown.sym} 40 70 0 0 {name=SIM only_toplevel=false value=".global VDD VSS
.lib cornerMOSlv.lib mos_tt
* Standard cells expanded from the PDK schematics by Xschem.
.temp 27
.control
save v(CLK) v(EN) v(N_POR) v(SYNC) v(EDGE) v(VDD) i(V_VDD)
tran 100n 2m 0 1u
meas tran edge_width TRIG v(EDGE) VAL=0.6 RISE=1 TARG v(EDGE) VAL=0.6 FALL=1
meas tran sync_rise WHEN v(SYNC)=0.6 RISE=1
meas tran edge_rise WHEN v(EDGE)=0.6 RISE=1
meas tran edge_second WHEN v(EDGE)=0.6 RISE=2
meas tran edge_held_high FIND v(EDGE) AT=800u
meas tran edge_after_fall FIND v(EDGE) AT=1.5m
write EN_INPUT_tb.raw
wrdata EN_INPUT_tb_signals.txt v(CLK) v(EN) v(N_POR) v(SYNC) v(EDGE)
.endc"}
C {launcher.sym} 1130 -560 0 0 {name=h5
descr="load waves"
tclcommand="xschem raw_read $netlist_dir/@schname\\\\.raw tran"
}
