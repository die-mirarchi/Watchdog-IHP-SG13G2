import sys,re,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P; import importlib, gen_integracion as IG
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
KEYS=['vR','vB','lat','T','nT','dl','dp','p']
def job(c):
    m,t,v=c; tries=[]
    for tm in ['100n','70n','130n','50n','150n']:
        tg=f'integ_{m}_{t}_{v}_{tm}'
        blk=IG.block(v,t,tm,plots=False).replace('@OUT@',f'{tg}.txt').replace('  set wr_singlescale','  set wr_singlescale\n  set wr_vecnames')
        top=f"""* integracion wd_oscillater + wd_por + wd_reset_sync(digital) -- mos_{m} {t} C {v} V
x1 POR_RAW_N VDD VSS wd_por
x2 POR_RAW_N CLK POR_B VDD VSS wd_reset_sync
x3 CLK VDD VSS wd_oscillater
C1 POR_B VSS 50f
.lib {MOD}/cornerMOSlv.lib mos_{m}
.lib {MOD}/cornerRES.lib res_typ
.lib {MOD}/cornerCAP.lib cap_typ
.include {SC}
"""
        n=top+blk+cellnet('wd_por')+cellnet('wd_oscillater')+'.end\n'
        log=run(n,tg)
        r={}
        for k in [a+w for a in KEYS for w in 'ABC']+['tD','pD','idd_ua','ok']:
            mm=re.search(r'^%s\s+=\s+([-\d.eE+]+)'%k,log,re.M|re.I)
            if mm: r[k]=float(mm.group(1))
        r['ok']='VEREDICTO: PASS' in log; r['abort']='aborted' in log; r['tmax']=tm
        tries.append((tm,r['ok'],r['abort']))
        if r['ok'] and not r['abort']: break
    r['tries']=tries
    d=load(f'{VAL}/out/{tg}.txt')
    return c,r,d
def plot(res):
    for m in CORNERS:
        rr=[(c,r,d) for c,r,d in res if c[0]==m]
        fig,ax=plt.subplots(figsize=(11,5.2))
        for (mm,t,v),r,d in rr:
            st=P.style(t,v); tt=d['time']*1e6
            for off,key in ((6,'vvdd'),(4.5,'vclk'),(3,'vpor_raw_n'),(1.5,'vx2p1'),(0,'vpor_b')):
                ax.plot(tt,d[key]/v+off,**st)
        for off,lab in ((6,'VDD'),(4.5,'CLK'),(3,'POR_RAW_N'),(1.5,'P1'),(0,'POR_B')): ax.text(-20,off+1.1,lab,fontsize=9,color=P.INK,fontweight='bold')
        for x,lab in ((0,'A: rampa 10 µs'),(400,'B: caída a 0,45 V'),(810,'C: apagado + rampa de 1 ms')): ax.text(x+5,7.55,lab,fontsize=8.5,color=P.INK2)
        ax.set(yticks=[],xlabel='t (µs)',ylim=(-0.2,7.9),xlim=(-25,2100)); ax.grid(axis='y',visible=False)
        P.legend(ax,loc='lower right',ncol=6,bbox_to_anchor=(1.0,1.0))
        fig.suptitle(f'Integración wd_oscillater + wd_por + wd_reset_sync · mos_{m} · {sum(r["ok"] for _,r,_ in rr)}/9 PASS',x=0.125,y=1.0,ha='left',fontsize=11,fontweight='bold')
        P.subtitle(fig,'Señales normalizadas a VDD. FF del sincronizador en XSPICE (el FF real se valida en wd_reset_sync). POR_B sube en el 2.º flanco de CLK tras POR_RAW_N en A, B y C.\nVDD al liberar POR_B en la rampa lenta (V): '+', '.join(f'{r["vBC"]:.2f}' for _,r,_ in rr))
        P.save(fig,f'{G}/integracion/{m}/integracion_{m}.png')
if __name__=='__main__' and len(sys.argv)>1:
    import json
    R=json.load(open(os.path.join(VAL,'res_integ.json')))
    plot([(tuple(c),r,load(f"{VAL}/out/integ_{c[0]}_{c[1]}_{c[2]}_{r['tmax']}.txt")) for c,r in R]); sys.exit()
if __name__=='__main__':
    import json
    res=pmap(job,grid()); plot(res)
    json.dump([(c,r) for c,r,_ in res],open(os.path.join(VAL,'res_integ.json'),'w'),indent=1,default=float)
    for c,r,_ in res: print(c,r['ok'],r['tries'],{k:round(r[k],3) for k in ['vRA','latA','TA','dlA','vRC','vBC','TC','dlC'] if k in r})
