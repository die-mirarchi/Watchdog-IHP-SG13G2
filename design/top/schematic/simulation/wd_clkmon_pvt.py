#!/usr/bin/env python3
# wd_clkmon_pvt.py -- wd_clkmon a nivel transistor en PVT (ngspice + PSP/OSDI), sobre el netlist exportado del top.
# Uso (desde esta carpeta, con PDK_ROOT definido): python3 wd_clkmon_pvt.py [wd_watchdog.spice] [NPROC=4 en el entorno]
# CLK ideal de T = 123 us (el periodo mas lento posible, peor caso de falsa deteccion):
#   0-1,5 ms corre; 1,5-6 ms detenido en 0; 6-7,5 ms corre; 7,5-12 ms detenido en 1; 12-13 ms corre.
# PASS: CLK_LOST = 0 con reloj, = 1 detenido, vuelve a 0 con el primer flanco; deteccion (desde el ultimo flanco) 185-2500 us.
# 34 casos: 5 MOS x -40/27/85 C x 1,08/1,32 V con MIM tipica + 4 esquinas de MIM. ~3 min con 4 procesos.
import os,re
import subprocess,itertools,json,sys
from concurrent.futures import ThreadPoolExecutor
P=os.environ['PDK_ROOT']+'/ihp-sg13g2'
NET=sys.argv[1] if len(sys.argv)>1 and not sys.argv[1].isdigit() else 'wd_watchdog.spice'
_t=open(NET).read().replace('\n+',' ')
sub='\n'.join(re.findall(r'^\.subckt (?:wd_clkmon|schmitt) .*?^\.ends',_t,re.S|re.M))
os.makedirs('clkmon_pvt',exist_ok=True)
T=123e-6; tr=10e-9
def clk_pwl(v):
    pts=[(0,0)]; lvl=0; t=0.0
    wins=[(0,1.5e-3),(6e-3,7.5e-3),(12e-3,13e-3)]
    edges=[]
    for i,(a,b) in enumerate(wins):
        t=a; e=[]
        while t+T/2<=b-1e-9:
            t+=T/2; e.append(t)
        # ventana 1 termina en 0 (cantidad par de flancos); ventana 2 termina en 1 (impar)
        if i==0 and len(e)%2: e=e[:-1]
        if i==1 and (len(edges)+len(e))%2==0: e=e[:-1]
        edges+=e
    # niveles: al comienzo 0; el estado se conserva entre ventanas; ventana 1 termina en 0, ventana 2 debe terminar en 1
    out=[]; lvl=0
    for e in edges:
        out.append((e,lvl)); lvl^=1; out.append((e+tr,lvl))
    return out, edges
def run(a):
    c,t,v,k=a
    pts,edges=clk_pwl(v)
    # nivel al final de cada ventana
    def lvl_at(x):
        l=0
        for e in edges:
            if e<x: l^=1
        return l
    l1=lvl_at(1.5e-3); l2=lvl_at(7.5e-3)
    last1=max(e for e in edges if e<1.5e-3); last2=max(e for e in edges if e<7.5e-3)
    pw=' '.join(f'{x:.9g} {y*v:.4g}' for x,y in [(0,0)]+pts)
    res={}
    for tm in ['0.5u','0.3u','0.7u']:
        net=f'''* wd_clkmon PVT
.lib {P}/libs.tech/ngspice/models/cornerMOSlv.lib {c}
.lib {P}/libs.tech/ngspice/models/cornerCAP.lib {k}
.include {P}/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
{sub}
.temp {t}
VDD VDD 0 PWL(0 0 10u {v})
VSS VSS 0 0
VCK CLK 0 PWL({pw})
x1 CLK CLK_LOST VDD VSS wd_clkmon
.option method=gear maxord=2 reltol=1e-3
.control
let vm={v}/2
tran 0.5u 13m 0 {tm}
meas tran fa1 MAX v(clk_lost) FROM=0.2m TO=1.5m
meas tran fa2 MAX v(clk_lost) FROM=6.07m TO=7.5m
meas tran fa3 MAX v(clk_lost) FROM=12.07m TO=13m
meas tran va1 MAX v(x1.a) FROM=0.3m TO={last1}
meas tran vb1 MAX v(x1.b) FROM=0.3m TO={last1}
meas tran va2 MAX v(x1.a) FROM=6.3m TO={last2}
meas tran vb2 MAX v(x1.b) FROM=6.3m TO={last2}
meas tran d0 WHEN v(clk_lost)=$&vm RISE=1 TD=1.5m
meas tran d1 WHEN v(clk_lost)=$&vm RISE=1 TD=7.5m
meas tran r1 FIND v(clk_lost) AT=6.07m
meas tran r2 FIND v(clk_lost) AT=12.07m
meas tran s0 FIND v(clk_lost) AT=5.9m
meas tran s1 FIND v(clk_lost) AT=11.9m
meas tran ia AVG i(VDD) FROM=0.5m TO=1.5m
echo RES $&fa1 $&fa2 $&fa3 $&va1 $&vb1 $&va2 $&vb2 $&d0 $&d1 $&r1 $&r2 $&s0 $&s1 $&ia
quit
.endc
.end
'''
        fn=f'clkmon_pvt/cm_{c}_{t}_{v}_{k}_{tm}.sp'; open(fn,'w').write(net)
        o=subprocess.run(['ngspice','-b',fn],capture_output=True,text=True).stdout
        L=[l for l in o.splitlines() if l.startswith('RES')]
        if L and len(L[0].split())==15:
            x=list(map(float,L[0].split()[1:]))
            fa=max(x[0:3]); vmax=max(x[3:7]); det0=(x[7]-last1)*1e6; det1=(x[8]-last2)*1e6
            ok = fa<v/2 and x[9]<v/2 and x[10]<v/2 and x[11]>v/2 and x[12]>v/2 and 185<det0<2500 and 185<det1<2500
            return dict(c=c,t=t,v=v,k=k,tm=tm,vmax=round(vmax*1e3),det0=round(det0),det1=round(det1),I=round(-x[13]*1e9),fa=round(fa,3),ok=ok,stop=(l1,l2))
    return dict(c=c,t=t,v=v,k=k,ok=None)
cs=['mos_tt','mos_ss','mos_ff','mos_sf','mos_fs']
jobs=[(c,t,v,'cap_typ') for c in cs for t in [-40,27,85] for v in [1.08,1.32]]
jobs+=[('mos_ss',-40,1.08,'cap_wcs'),('mos_ss',85,1.08,'cap_wcs'),('mos_ff',-40,1.32,'cap_bcs'),('mos_ff',85,1.32,'cap_bcs')]

with ThreadPoolExecutor(int(os.environ.get('NPROC','4'))) as ex: R=list(ex.map(run,jobs))
json.dump(R,open('wd_clkmon_pvt.json','w'),indent=1)
for r in R: print(r)
n=sum(1 for r in R if r.get('ok')); print('PASS',n,'/',len(R))
G=[r for r in R if r.get('ok')]
if G: print('deteccion %d-%d us; V_A,V_B max con reloj %d-%d mV; consumo %d-%d nA'%(min(min(r['det0'],r['det1']) for r in G),max(max(r['det0'],r['det1']) for r in G),min(r['vmax'] for r in G),max(r['vmax'] for r in G),min(r['I'] for r in G),max(r['I'] for r in G)))
print('VEREDICTO: PASS' if n==len(R) else 'VEREDICTO: FAIL')
