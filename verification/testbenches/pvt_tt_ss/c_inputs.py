import sys,re,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P; import gen_reset_sync as gen
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
T=100e-6; E0=50e-6
EDGES=[E0+k*T for k in range(17)]
# pulsos de entrada (subida, bajada) respecto de flancos de CLK
PULSES=[(250e-6+30e-6, 250e-6+30e-6+350e-6),     # a mitad de ciclo, 3,5 T
        (850e-6-5e-9, 850e-6-5e-9+250e-6),        # 5 ns antes de un flanco, 2,5 T
        (1250e-6+5e-9,1250e-6+5e-9+200e-6)]       # 5 ns despues de un flanco, 2 T
GLITCH=(1160e-6,1180e-6)                           # 20 us entre flancos (1150 y 1250): no debe detectarse
TEND=1600e-6
def stim(v):
    pts=['0 0']
    for a,b in sorted(PULSES+[GLITCH]):
        pts+=[f'{a:.12g} 0',f'{a+1e-9:.12g} {v}',f'{b:.12g} {v}',f'{b+1e-9:.12g} 0']
    return 'PWL('+' '.join(pts)+')'
def bk():
    ev=EDGES+[e+50e-6 for e in EDGES]+[x for p in PULSES+[GLITCH] for x in p]+[120e-6]
    pts=['0 0']; s=0
    for e in sorted(ev):
        for j in range(-40,121):
            s=1e-3-s; pts.append(f'{e+j*25e-12:.13g} {s:.3g}')
    return '\n+ '.join(' '.join(pts[i:i+8]) for i in range(0,len(pts),8))
def job(c,cell):
    m,t,v=c; tg=f'{cell}_{m}_{t}_{v}'
    if cell=='EN_INPUT': inst='XDUT PORB CLK SYNC IN EDGE VDD VSS EN_INPUT'; sync='v(sync)'
    else: inst='XDUT PORB CLK IN EDGE VDD VSS WDI_INPUT'; sync='v(xdut.wdi_sync)'
    n=header(m,t,v,f'{cell}: sincronizador + detector de flanco')+cellnet(cell)+f"""
VDD VDD 0 PWL(0 0 10u {v})
VSS VSS 0 0
VCK CKI 0 PULSE(0 {v} 50u 2n 2n 50u 100u)
XCKB CLK CKI VDD VSS sg13g2_buf_4
CCLK CLK 0 200f
VPOR PORB 0 PWL(0 0 120u 0 120.001u {v})
VIN IN 0 {stim(v)}
{inst}
CEDGE EDGE 0 10f
* VBK: sin efecto electrico; pasos de 25 ps alrededor de flancos (evita el artefacto de FF)
VBK BK 0 PWL({bk()})
RBK BK 0 1k
.control
set wr_singlescale
set wr_vecnames
tran 1n {TEND*1e6:.0f}u 0 100n
wrdata {tg}.txt v(vdd) v(clk) v(in) {sync} v(edge) v(porb)
.endc
.end
"""
    log=run(n,tg); d=load(f'{VAL}/out/{tg}.txt')
    return evaluate(c,d,'aborted' in log)
def evaluate(c,d,ab=False):
    m,t,v=c
    tt=d['time']; e=d['vedge']; ck=d['vclk']
    def cr(y,up=True):
        s=np.sign(y-v/2); i=np.where(np.diff(s)>0 if up else np.diff(s)<0)[0]
        return np.array([tt[j]+(tt[j+1]-tt[j])*(v/2-y[j])/(y[j+1]-y[j]) for j in i])
    eu,ed=cr(e),cr(e,False); cu=cr(ck)
    lat=[];wid=[];al=[]
    for (a,b) in PULSES:
        x=eu[(eu>a)&(eu<b+3*T)]
        if not len(x): lat.append(None); continue
        lat.append((x[0]-a)/T); y=ed[ed>x[0]]; wid.append((y[0]-x[0])/T if len(y) else None)
        al.append(min(abs(x[0]-cu)))
    glitch=int(np.sum((eu>GLITCH[0])&(eu<PULSES[2][0]+T)))
    ok=bool(len(eu)==3 and all(l is not None and 0.99<=l<=2.01 for l in lat) and all(w is not None and abs(w-1)<2e-4 for w in wid) and max(al)<20e-9 and glitch==0)
    return c,dict(n_edges=len(eu),lat_T=lat,width_T=wid,align_ns=[a*1e9 for a in al],glitch=glitch,ok=ok,abort=ab),d
def plot(res,cell):
    sync_key='vsync' if cell=='EN_INPUT' else 'vxdutwdi_sync'
    names=('EN','SYNC','EDGE') if cell=='EN_INPUT' else ('WDI_IN','WDI_SYNC','WDI_EDGE')
    for m in CORNERS:
        rr=[(c,r,d) for c,r,d in res if c[0]==m]
        fig,ax=plt.subplots(figsize=(10,4.8))
        for (mm,t,v),r,d in rr:
            st=P.style(t,v); tt=d['time']*1e6
            for off,key in ((6,'vclk'),(4.5,'vporb'),(3,'vin'),(1.5,sync_key),(0,'vedge')):
                ax.plot(tt,d[key]/v+off,**st)
        for off,lab in ((6,'CLK'),(4.5,'POR_B'),(3,names[0]),(1.5,names[1]+' (interno)' if cell!='EN_INPUT' else names[1]),(0,names[2])):
            ax.text(-5,off+1.1,lab,fontsize=9,color=P.INK,fontweight='bold')
        ax.axvspan(GLITCH[0]*1e6,GLITCH[1]*1e6,color='#eda100',alpha=0.12,lw=0); ax.text(GLITCH[0]*1e6+3,3.55,'pulso de 20 µs\nentre flancos',fontsize=7.5,color=P.INK2)
        ax.set(yticks=[],xlabel='t (µs)',ylim=(-0.2,7.4),xlim=(0,TEND*1e6)); ax.grid(axis='y',visible=False)
        P.legend(ax,loc='lower right',ncol=6,bbox_to_anchor=(1.0,1.0))
        fig.suptitle(f'{cell} · mos_{m} · sincronización (2 FF) y detección de flanco · {sum(r["ok"] for _,r,_ in rr)}/9 PASS',x=0.125,y=1.0,ha='left',fontsize=11,fontweight='bold')
        r0=rr[0][1]
        P.subtitle(fig,'Señales normalizadas a VDD. Entrada que sube a mitad de ciclo, 5 ns antes y 5 ns después de un flanco: latencia '+', '.join(f'{x:.2f}' for x in r0['lat_T'])+' T; ancho del pulso de flanco = 1 T en todos los casos; el pulso corto no se detecta.')
        P.save(fig,f'{G}/{cell}/{m}/{cell}_{m}_deteccion.png')
if __name__=='__main__':
    import json
    re_eval=len(sys.argv)>1 and sys.argv[1]=='reeval'
    cells=[a for a in sys.argv[1:] if a!='reeval'] or ['EN_INPUT','WDI_INPUT']
    for cell in cells:
        if re_eval: res=[evaluate(c,load(f'{VAL}/out/{cell}_{c[0]}_{c[1]}_{c[2]}.txt')) for c in grid()]
        else: res=pmap(lambda c:job(c,cell),grid())
        plot(res,cell)
        json.dump([(c,r) for c,r,_ in res],open(f'/home/claude/val/res_{cell}.json','w'),indent=1,default=float)
        for c,r,_ in res: print(cell,c,r['ok'],r['n_edges'],[round(x,4) if x else x for x in r['lat_T']],[round(x,5) if x else x for x in r['width_T']],[round(x,2) for x in r['align_ns']],r['glitch'])
