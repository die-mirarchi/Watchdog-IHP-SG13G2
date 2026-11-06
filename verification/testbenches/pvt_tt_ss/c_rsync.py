import sys,re,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P; import gen_reset_sync as gen
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
DEL=gen.DELTAS
def rs_job(c):
    m,t,v=c; tg=f'rsync_{m}_{t}_{v}'
    n=gen.tb('mos_'+m,t,v,paths={'M':MOD,'SC':SC},out=f'{tg}.txt')
    a=n.index('** DUT'); b=n.index('.ends',a)+5
    n=n[:a]+cellnet('wd_reset_sync')+n[b:]
    n=n.replace('XDUT CLK POR_RAW_N PORB VDD VSS wd_reset_sync','XDUT POR_RAW_N CLK PORB VDD VSS wd_reset_sync').replace('set wr_singlescale','set wr_singlescale\nset wr_vecnames')
    log=run(n,tg)
    r={k:float(mm.group(1)) for k in [f'{p}{s}' for p in ('d','ph','q','a','p') for s in range(8)]+['ok'] if (mm:=re.search(r'^%s\s+=\s+([-\d.eE+]+)'%k,log,re.M))}
    r['ok']=('VEREDICTO: PASS' in log)
    d=load(f'{VAL}/out/{tg}.txt'); return c,r,d
def rs_plot(res):
    rel=[100e-6+300e-6*s+50e-6+gen.u(x) for s,x in enumerate(DEL)]
    for m in CORNERS:
        rr=[(c,r,d) for c,r,d in res if c[0]==m]
        s0=3; t0=rel[s0]
        fig,ax=plt.subplots(figsize=(9.5,4.6))
        for (mm,t,v),r,d in rr:
            st=P.style(t,v); tt=d['time']; k=(tt>t0-30e-6)&(tt<t0+230e-6)
            for off,key in ((4.5,'vclk'),(3.0,'vpor_raw_n'),(1.5,'vxdutp1'),(0,'vporb')):
                ax.plot((tt[k]-t0)*1e6,d[key][k]/v+off,**st)
        for off,lab in ((4.5,'CLK'),(3.0,'POR_RAW_N'),(1.5,'P1'),(0,'POR_B')): ax.text(-29,off+1.12,lab,fontsize=9,color=P.INK,fontweight='bold')
        ax.set(yticks=[],xlabel='t − liberación de POR_RAW_N (µs)',ylim=(-0.2,6.0)); ax.grid(axis='y',visible=False)
        P.legend(ax,loc='upper right',ncol=2,bbox_to_anchor=(1.0,0.9))
        ax.set_title(f'wd_reset_sync · mos_{m} · liberación a 10 ns de un flanco: P1 en el 1.er flanco, POR_B en el 2.º · {sum(r["ok"] for _,r,_ in rr)}/9 PASS',loc='left',fontsize=10)
        P.subtitle(fig,'Señales normalizadas a VDD. Latencia (períodos) para δ = −50 µs, −1 µs, −100 ns, −10 ns, −1 ns, 0, +1 ns, +10 ns: '+', '.join(f'{rr[0][1][f"d{s}"]:.2f}' for s in range(8))+' (iguales en las 9 condiciones)')
        P.save(fig,f'{G}/wd_reset_sync/{m}/rsync_{m}_liberacion.png')
        # zoom flanco
        fig,ax=plt.subplots(1,2,figsize=(9.5,3.6))
        te=t0+10e-9+100e-6  # flanco donde sube POR_B (2.o)
        ta=100e-6+300e-6*s0+290e-6
        for (mm,t,v),r,d in rr:
            st=P.style(t,v); tt=d['time']
            k=(tt>te-0.5e-9)&(tt<te+5e-9); ax[0].plot((tt[k]-te)*1e9,d['vclk'][k]/v,**st); ax[0].plot((tt[k]-te)*1e9,d['vporb'][k]/v,**st)
            k=(tt>ta-0.5e-9)&(tt<ta+4e-9); ax[1].plot((tt[k]-ta)*1e9,d['vpor_raw_n'][k]/v,**st); ax[1].plot((tt[k]-ta)*1e9,d['vporb'][k]/v,**st)
        ax[0].set(title='Flanco de CLK → POR_B (liberación)',xlabel='t − flanco (ns)',ylabel='V / VDD')
        ax[1].set(title='POR_RAW_N ↓ → POR_B ↓ (aserción asíncrona)',xlabel='t − bajada de POR_RAW_N (ns)')
        ax[0].annotate('CLK',(1.45,0.6),(0.3,0.75),fontsize=8.5,color=P.INK2,arrowprops=dict(arrowstyle='-',color=P.INK2,lw=0.6)); ax[0].annotate('POR_B',(2.6,0.5),(3.4,0.3),fontsize=8.5,color=P.INK2,arrowprops=dict(arrowstyle='-',color=P.INK2,lw=0.6))
        P.legend(ax[1],loc='center right',ncol=1)
        fig.suptitle(f'wd_reset_sync · mos_{m} · retardos de conmutación',x=0.01,ha='left',fontsize=11,fontweight='bold'); fig.tight_layout()
        P.save(fig,f'{G}/wd_reset_sync/{m}/rsync_{m}_retardos.png')
def replot():
    import json
    R={tuple(c):r for c,r in json.load(open('/home/claude/val/res_rsync.json'))}
    rs_plot([(c,R[c],load(f'{VAL}/out/rsync_{c[0]}_{c[1]}_{c[2]}.txt')) for c in grid()])
if __name__=='__main__' and len(sys.argv)>1: replot(); sys.exit()
if __name__=='__main__':
    import json
    res=pmap(rs_job,grid()); rs_plot(res)
    json.dump([(c,r) for c,r,_ in res],open('/home/claude/val/res_rsync.json','w'),indent=1,default=float)
    for c,r,_ in res: print(c,r['ok'],[round(r.get(f'd{s}',-9),3) for s in range(8)],[round(r.get(f'a{s}',-9)*1e9,2) for s in range(2)])
