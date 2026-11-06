import sys,re,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
TPL=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'tb_wd_por_template.spice')).read()
KEYS=['va','vc','vf','vg','vh','vd','dd','de','iua','blmax','p_lvl','p_blip','p_dip','p_fast','p_cut','p_idd','pass']
def por_job(c):
    m,t,v=c
    for tm in ['1u','0.5u']:
        tg=f'por_{m}_{t}_{v}_{tm}'
        dut=f'{VAL}/out/wd_por_cell.spice'; open(dut,'w').write(cellnet('wd_por'))
        n=TPL
        for k,x in dict(MOS='mos_'+m,RES='res_typ',CAP='cap_typ',TEMP=t,VH=v,MODELS=MOD,STDCELL=SC,DUT=dut,TMAX=tm,OUT=f'{tg}.txt').items(): n=n.replace('@%s@'%k,str(x))
        n=n.replace('XDUT VDD VSS POR_RAW_N wd_por','XDUT POR_RAW_N VDD VSS wd_por').replace('set wr_singlescale','set wr_singlescale\nset wr_vecnames')
        log=run(n,tg)
        r={k:float(mm.group(1)) for k in KEYS if (mm:=re.search(r'^%s\s+=\s+([-\d.eE+]+)'%k,log,re.M))}
        r['ok']=('VEREDICTO: PASS' in log); r['tmax']=tm
        if r['ok']: break
    d=load(f'{VAL}/out/{tg}.txt')
    return c,r,d
def por_plot(res):
    for m in CORNERS:
        rr=[(c,r,d) for c,r,d in res if c[0]==m]
        # (a) POR_RAW_N vs VDD en rampa lenta de subida (A) y bajada (C)
        fig,ax=plt.subplots(figsize=(7.2,4.3))
        for (mm,t,v),r,d in rr:
            s=P.style(t,v); tt=d['time']
            for a,b in ((0,1000e-6),(2000e-6,3000e-6)):
                k=(tt>a)&(tt<b); ax.plot(d['vvdd'][k],d['vpor_raw_n'][k],**s)
        ax.plot([0,1.32],[0,1.32],color=P.GRID,lw=1,zorder=0); ax.text(1.0,1.05,'VDD',color=P.INK2,fontsize=8)
        ax.axvline(1.08,color=P.INK2,lw=0.8,ls=(0,(2,2))); ax.text(1.085,0.05,'VDD mín 1,08 V',color=P.INK2,fontsize=8)
        ax.set(xlabel='VDD (V) — rampa de 1 ms subiendo y bajando',ylabel='V(POR_RAW_N) (V)',xlim=(0,1.34))
        P.legend(ax,loc='upper left',ncol=2)
        ax.set_title(f'wd_por · mos_{m} · umbral de liberación (rampa lenta) · {sum(r["ok"] for _,r,_ in rr)}/9 PASS',loc='left')
        P.subtitle(fig,'Umbral subida/bajada (V): '+', '.join(f'{r["va"]:.3f}/{r["vc"]:.3f}' for _,r,_ in rr)+' — sin histéresis; independiente de la rampa (1 µs … 10 ms)')
        P.save(fig,f'{G}/wd_por/{m}/por_{m}_umbral_rampa_lenta.png')
        # (b) rampa rapida y corte
        fig,ax=plt.subplots(2,2,figsize=(10,5.6),sharey='row')
        for (mm,t,v),r,d in rr:
            s=P.style(t,v); tt=d['time']
            for j,(a,b,t0) in enumerate(((3099e-6,3106e-6,3100e-6),(3199e-6,3218e-6,3200e-6))):
                k=(tt>a)&(tt<b)
                ax[0,j].plot((tt[k]-t0)*1e6,d['vxdutdelay'][k],**s); ax[1,j].plot((tt[k]-t0)*1e6,d['vpor_raw_n'][k],**s)
        ax[0,0].set(title='Rampa de VDD en 1 µs (desde 0)',ylabel='V(DELAY) (V)'); ax[0,1].set(title='Corte de 10 µs y vuelta en 1 µs')
        ax[1,0].set(xlabel='t − inicio de rampa (µs)',ylabel='V(POR_RAW_N) (V)'); ax[1,1].set(xlabel='t − inicio del corte (µs)')
        P.legend(ax[1,0],loc='upper left',ncol=2)
        fig.suptitle(f'wd_por · mos_{m} · filtro RC y descarga por MDIS',x=0.01,ha='left',fontsize=11,fontweight='bold'); fig.tight_layout()
        P.subtitle(fig,'Retardo de liberación tras rampa de 1 µs (µs): '+', '.join(f'{r["dd"]:.2f}' for _,r,_ in rr)+'  ·  tras corte: '+', '.join(f'{r["de"]:.2f}' for _,r,_ in rr))
        P.save(fig,f'{G}/wd_por/{m}/por_{m}_rampa_rapida_y_corte.png')
        # (c) resumen
        fig,ax=plt.subplots(1,2,figsize=(9.5,3.4))
        for v in VDDS:
            pts=[(t,r) for (mm,t,vv),r,_ in rr if vv==v]
            ax[0].plot([t for t,_ in pts],[r['va'] for _,r in pts],color=P.INK2,linestyle=P.VLS[v],marker='o',ms=6,label=f'{v:.2f} V')
            ax[1].plot([t for t,_ in pts],[r['iua'] for _,r in pts],color=P.INK2,linestyle=P.VLS[v],marker='o',ms=6,label=f'{v:.2f} V')
        ax[0].axhspan(0.45,1.03,color='#1baf7a',alpha=0.06,lw=0)
        ax[0].set(title='Umbral de liberación vs T',xlabel='T (°C)',ylabel='VDD de liberación (V)',xticks=TEMPS,ylim=(0.4,1.1))
        ax[1].set(title='Consumo estático vs T',xlabel='T (°C)',ylabel='I_DD (µA)',xticks=TEMPS)
        ax[0].legend(fontsize=8.5); fig.suptitle(f'wd_por · mos_{m} · resumen (ventana válida 0,45–1,03 V)',x=0.01,ha='left',fontsize=11,fontweight='bold'); fig.tight_layout()
        P.save(fig,f'{G}/wd_por/{m}/por_{m}_resumen.png')
if __name__=='__main__':
    import json
    res=pmap(por_job,grid()); por_plot(res)
    json.dump([(c,r) for c,r,_ in res],open('/home/claude/val/res_por.json','w'),indent=1,default=float)
    for c,r,_ in res: print(c,r['ok'],r.get('tmax'),{k:round(r[k],3) for k in ['va','vc','vf','vh','dd','de','iua','blmax'] if k in r})
