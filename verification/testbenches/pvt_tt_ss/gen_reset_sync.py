# genera tb_wd_reset_sync (una corrida, 8 liberaciones con distinta fase respecto de CLK)
DELTAS=['-50u','-1u','-100n','-10n','-1n','0','1n','10n']
def u(x):
    m={'u':1e-6,'n':1e-9}; return float(x[:-1])*m[x[-1]] if x[-1] in m else float(x)
def bk(rel,asr,jmax=120,dt=25e-12):
    edges=[50e-6+k*50e-6 for k in range(0,50)]+rel+asr
    pts=['0 0']; v=0
    for e in sorted(edges):
        for j in range(-int(1e-9/dt),jmax+1):
            v=1e-3-v; pts.append(f'{e+j*dt:.13g} {v:.3g}')
    return '\n+ '.join(' '.join(pts[i:i+8]) for i in range(0,len(pts),8))
def tb(mos='mos_tt',temp=27,vh=1.2,clkbuf='sg13g2_buf_4',cclk='200f',tmax='100n',header=True,paths=None,out=None,bkend=3e-9,bkdt=25e-12):
    T=100e-6
    rel=[100e-6+300e-6*s+50e-6+u(d) for s,d in enumerate(DELTAS)]
    asr=[100e-6+300e-6*s+290e-6 for s in range(8)]
    pwl=['0 0']
    for r,a in zip(rel,asr):
        pwl+= [f'{r:.12g} 0', f'{r+1e-9:.12g} {{VH}}', f'{a:.12g} {{VH}}', f'{a+1e-9:.12g} 0']
    pwl='\n+ '.join(' '.join(pwl[i:i+6]) for i in range(0,len(pwl),6))
    L=[]
    if paths:
        L+=[f".lib {paths['M']}/cornerMOSlv.lib {mos}",f".lib {paths['M']}/cornerRES.lib res_typ",f".lib {paths['M']}/cornerCAP.lib cap_typ",f".include {paths['SC']}"]
    else:
        L+=[f".lib cornerMOSlv.lib {mos}",".lib cornerRES.lib res_typ",".lib cornerCAP.lib cap_typ",".include sg13g2_stdcell.spice"]
    L+=[f".temp {temp}",f".param VH={vh}",".option method=gear maxord=2 reltol=1e-3","",
'''** DUT
.subckt wd_reset_sync CLK POR_RAW_N PORB VDD VSS
XF1 P1 P1_N CLK VDD POR_RAW_N VDD VSS sg13g2_dfrbp_1
XF2 PORB PORB_N CLK P1 POR_RAW_N VDD VSS sg13g2_dfrbp_1
.ends
''',
"* alimentacion: rampa de 10 us",
"VDD VDD 0 PWL(0 0 10u {VH})","VSS VSS 0 0",
"* reloj: fuente ideal 10 kHz (flancos de subida en 50u + k*100u) -> buffer del oscilador -> carga del arbol de reloj",
"VCK CKI 0 PULSE(0 {VH} 50u 2n 2n 50u 100u)",
f"XCKB CLK CKI VDD VSS {clkbuf}",f"CCLK CLK 0 {cclk}",
"* POR_RAW_N: 8 liberaciones con fase delta respecto del flanco (150u + 300u*s): "+' '.join(DELTAS),
"*            y 8 aserciones a mitad de ciclo (390u + 300u*s)",
"VPOR POR_RAW_N 0 PWL("+pwl+")",
"XDUT CLK POR_RAW_N PORB VDD VSS wd_reset_sync",
"* VBK: fuente auxiliar SIN efecto electrico. Solo pone puntos de quiebre cada 25 ps alrededor de",
"* cada flanco de CLK y de POR_RAW_N (-1 ns..+3 ns). Sin esto, con paso de decenas de ns el maestro",
"* y el esclavo del FF conmutan en el mismo paso y PORB cambia en el flanco de BAJADA (artefacto numerico).",
"VBK BK 0 PWL("+bk(rel,asr,int(bkend/bkdt),bkdt)+")","RBK BK 0 1k",
"* carga de PORB: R_B de ~25 FF + XOUT + cableado","CPORB PORB 0 100f","",
".control",f"tran 1n 2500u 0 {tmax}",
"let T = 100u","let VM = {VH}/2".replace('{VH}',str(vh)),
"let ok = 1"]
    for s,(r,a) in enumerate(zip(rel,asr)):
        end=a-5e-6
        L+=[f"* --- segmento {s}: delta = {DELTAS[s]} ---",
            f"let tP{s}=-1","let tQ%d=-1"%s, f"let tG{s}=-1", f"let tF{s}=-1",
            f"meas tran tP{s} when v(porb)=VM rise=1 from={r:.12g} to={end:.12g}",
            f"meas tran tQ{s} when v(xdut.p1)=VM rise=1 from={r:.12g} to={end:.12g}",
            f"meas tran tG{s} when v(porb)=VM rise=2 from={r:.12g} to={end:.12g}",
            f"meas tran tF{s} when v(porb)=VM fall=1 from={a:.12g} to={a+5e-6:.12g}",
            f"let d{s} = (tP{s} - {r:.12g})/T",
            f"let ph{s} = (tP{s} - 50u) - T*floor((tP{s} - 50u)/T + 0.5)",
            f"let q{s} = (tP{s} - tQ{s} - T)",
            f"let a{s} = tF{s} - {a:.12g}",
            f"let p{s} = (tP{s} gt 0) & (d{s} ge 0.999) & (d{s} le 2.0005) & (ph{s} ge 0) & (ph{s} le 20n) & (abs(q{s}) le 20n) & (tG{s} lt 0) & (tF{s} gt 0) & (a{s} le 100n)",
            f"let ok = ok & p{s}"]
    L+=["echo RESULT_BEGIN",
        "print "+' '.join(f'd{s}' for s in range(8)),
        "print "+' '.join(f'ph{s}' for s in range(8)),
        "print "+' '.join(f'q{s}' for s in range(8)),
        "print "+' '.join(f'a{s}' for s in range(8)),
        "print "+' '.join(f'p{s}' for s in range(8))+" ok",
        "echo RESULT_END",
        "if ok > 0.5","  echo VEREDICTO: PASS","else","  echo VEREDICTO: FAIL","end"]
    if out: L+=["set wr_singlescale",f"wrdata {out} v(clk) v(por_raw_n) v(xdut.p1) v(porb)"]
    else: L+=["plot v(clk) v(por_raw_n) v(xdut.p1)+1.5 v(porb)+3"]
    L+=[".endc",".end"]
    return '\n'.join(L)+'\n'
