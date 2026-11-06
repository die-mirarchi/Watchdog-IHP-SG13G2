import sys,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
def cross(t,y,thr,rising=True):
    s=np.sign(y-thr); i=np.where(np.diff(s)>0)[0] if rising else np.where(np.diff(s)<0)[0]
    return np.array([t[j]+(t[j+1]-t[j])*(thr-y[j])/(y[j+1]-y[j]) for j in i])
def osc_once(c,tmax):
    m,t,v=c; tg=f'osc_{m}_{t}_{v}_{tmax}'
    n=header(m,t,v,'wd_oscillater: arranque y regimen')+cellnet('wd_oscillater')+f"""
XO CLK VDD VSS wd_oscillater
CCLK CLK 0 200f
VDD VDD 0 PWL(0 0 10u {v})
VSS VSS 0 0
.control
set wr_singlescale
set wr_vecnames
tran 10n 700u 0 {tmax}
wrdata {tg}.txt v(vdd) v(clk) v(xo.vc) v(xo.vh) v(xo.vl) i(vdd)
.endc
.end
"""
    log=run(n,tg)
    try: d=load(f'{VAL}/out/{tg}.txt')
    except Exception: return None,d if False else None
    tt=d['time']; vc=d['vxovc']; clk=d['vclk']; vh=d['vxovh']
    k=tt>250e-6
    up=cross(tt[k],vc[k],v/2); dn=cross(tt[k],vc[k],v/2,False)
    if len(up)<3: return dict(ok=False,why='no oscila'),d
    T=np.mean(np.diff(up[:4]))
    dn2=dn[dn>up[0]]; duty=np.mean((dn2[:len(up)-1]-up[:len(dn2[:len(up)-1])])/T) if len(dn2) else np.nan
    cu=cross(tt[k],clk[k],v/2); Tc=np.mean(np.diff(cu[:4])) if len(cu)>=3 else np.nan
    i0=np.where((vc>=vh-0.01)&(tt>15e-6))[0]; tsu=tt[i0[0]] if len(i0) else np.nan
    idd=lambda a,b: -np.mean(d['ivdd'][(tt>a)&(tt<b)])*1e6
    I=min(idd(300e-6,500e-6),idd(500e-6,700e-6))
    ok=bool(0.8e-4<T<1.2e-4 and 0.45<duty<0.55 and abs(Tc/T-1)<0.01 and tsu<150e-6)
    return dict(T_us=T*1e6,duty=duty,Tclk_us=Tc*1e6,tsu_us=tsu*1e6,idd_ua=I,tmax=tmax,ok=ok,abort='aborted' in log),d
def osc_job(c):
    for tm in ['0.1u','0.07u','0.13u']:
        r,d=osc_once(c,tm)
        if r and r['ok']: return c,r,d
    return c,r,d
def osc_plot(res):
    for m in CORNERS:
        rr=[(c,r,d) for c,r,d in res if c[0]==m]
        fig,ax=plt.subplots(2,1,figsize=(9.5,6.4),gridspec_kw=dict(height_ratios=[1.25,1]))
        for (mm,t,v),r,d in rr:
            s=P.style(t,v); ax[0].plot(d['time']*1e6,d['vxovc'],**s)
            k=(d['time']>250e-6)&(d['time']<480e-6); ax[1].plot(d['time'][k]*1e6,d['vclk'][k],**s)
        ax[0].set(title='VC (tensión en CT): arranque y régimen',xlabel='t (µs)',ylabel='V')
        ax[1].set(title='CLK (salida, carga 200 fF)',xlabel='t (µs)',ylabel='V')
        P.legend(ax[0],loc='lower right',ncol=2)
        fig.suptitle(f'wd_oscillater · mos_{m} · rampa de VDD 10 µs · {sum(r["ok"] for _,r,_ in rr)}/9 PASS',x=0.01,ha='left',fontsize=11,fontweight='bold')
        fig.tight_layout()
        P.subtitle(fig,'Período (µs): '+', '.join(f'{r["T_us"]:.2f}' for _,r,_ in rr)+'  ·  duty '+f'{min(r["duty"] for _,r,_ in rr)*100:.1f}–{max(r["duty"] for _,r,_ in rr)*100:.1f} %'+'  ·  I_DD '+f'{min(r["idd_ua"] for _,r,_ in rr):.1f}–{max(r["idd_ua"] for _,r,_ in rr):.1f} µA')
        P.save(fig,f'{G}/wd_oscillater/{m}/osc_{m}_formas_de_onda.png')
        # resumen: periodo vs T
        fig,ax=plt.subplots(1,2,figsize=(9.5,3.4))
        for v in VDDS:
            pts=[(t,r) for (mm,t,vv),r,_ in rr if vv==v]
            ax[0].plot([t for t,_ in pts],[r['T_us'] for _,r in pts],color=P.INK2,linestyle=P.VLS[v],marker='o',ms=6,label=f'{v:.2f} V')
            ax[1].plot([t for t,_ in pts],[r['idd_ua'] for _,r in pts],color=P.INK2,linestyle=P.VLS[v],marker='o',ms=6,label=f'{v:.2f} V')
        ax[0].axhspan(80,120,color='#1baf7a',alpha=0.06,lw=0); ax[0].axhline(100,color=P.GRID,lw=1)
        ax[0].set(title='Período vs temperatura',xlabel='T (°C)',ylabel='T_osc (µs)',xticks=TEMPS,ylim=(97,104))
        ax[1].set(title='Consumo vs temperatura',xlabel='T (°C)',ylabel='I_DD (µA)',xticks=TEMPS)
        ax[0].legend(fontsize=8.5); fig.suptitle(f'wd_oscillater · mos_{m} · resumen (objetivo 100 µs ± 20 %)',x=0.01,ha='left',fontsize=11,fontweight='bold'); fig.tight_layout()
        P.save(fig,f'{G}/wd_oscillater/{m}/osc_{m}_resumen.png')
if __name__=='__main__':
    import json
    res=pmap(osc_job,grid()); osc_plot(res)
    json.dump([(c,r) for c,r,_ in res],open('/home/claude/val/res_osc.json','w'),indent=1,default=float)
    for c,r,_ in res: print(c,{k:(round(x,3) if isinstance(x,float) else x) for k,x in r.items()})
