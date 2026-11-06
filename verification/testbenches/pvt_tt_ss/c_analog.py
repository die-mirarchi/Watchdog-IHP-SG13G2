import sys,os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import *; import plot as P
import matplotlib.pyplot as plt
G='/home/claude/val/graphs'
def tag(cell,m,t,v): return f'{cell}_{m}_{t}_{v}'
def ctl(lines): return '.control\nset wr_singlescale\nset wr_vecnames\n'+'\n'.join(lines)+'\n.endc\n.end\n'
# ---------- bias ----------
def bias_job(c):
    m,t,v=c; tg=tag('bias',m,t,v)
    n=header(m,t,v,'bias: arranque con rampa de VDD')+cellnet('bias')+f"""
XB VBP VBN VDD VSS bias
VDD VDD 0 PWL(0 0 10u {v})
VSS VSS 0 0
"""+ctl(['tran 10n 60u 0 50n',f'wrdata {tg}.txt v(vdd) v(vbn) v(vbp) i(vdd)'])
    log=run(n,tg); d=load(f'{VAL}/out/{tg}.txt')
    vbn,vbp,idd=d['vvbn'][-1],d['vvbp'][-1],-d['ivdd'][-1]*1e6
    k=d['time']>50e-6; drift=abs(d['vvbn'][k][-1]-d['vvbn'][k][0])
    ok=(0.3<vbn<0.7)and(0.3<v-vbp<0.75)and(1.0<idd<4.0)and drift<2e-3
    return c,dict(vbn=vbn,vsg_p=v-vbp,idd_ua=idd,ok=bool(ok)),d
def bias_plot(res):
    for m in CORNERS:
        fig,ax=plt.subplots(1,2,figsize=(10,3.6))
        for (mm,t,v),r,d in res:
            if mm!=m: continue
            s=P.style(t,v); ax[0].plot(d['time']*1e6,d['vvbn'],**s); ax[1].plot(d['time']*1e6,d['vdd']-d['vvbp'] if 'vdd' in d.dtype.names else d['vvdd']-d['vvbp'],**s)
        ax[0].set(title='VBN (diodo NMOS)',xlabel='t (µs)',ylabel='V'); ax[1].set(title='VDD − VBP (V_SG del diodo PMOS)',xlabel='t (µs)',ylabel='V')
        P.legend(ax[1],loc='lower right',ncol=2)
        rr=[r for (mm,_,_),r,_ in res if mm==m]
        fig.suptitle(f'bias · mos_{m} · rampa de VDD 0→VDD en 10 µs · {sum(r["ok"] for r in rr)}/9 PASS',x=0.01,y=1.04,ha='left',fontsize=11,fontweight='bold')
        P.subtitle(fig,'I_DD total (rama de referencia + espejo): '+', '.join(f'{r["idd_ua"]:.2f}' for r in rr)+' µA')
        P.save(fig,f'{G}/bias/{m}/bias_{m}_arranque.png')
# ---------- schmitt ----------
def schmitt_job(c):
    m,t,v=c; tg=tag('schmitt',m,t,v)
    n=header(m,t,v,'schmitt: barrido DC subida/bajada')+cellnet('schmitt')+f"""
XS IN OUT VDD VSS schmitt
VDD VDD 0 {v}
VSS VSS 0 0
VIN IN 0 0
"""+ctl([f'dc VIN 0 {v} 0.5m',f'wrdata {tg}_up.txt v(in) v(out)',f'dc VIN {v} 0 -0.5m',f'wrdata {tg}_dn.txt v(in) v(out)'])
    run(n,tg); u=load(f'{VAL}/out/{tg}_up.txt'); d=load(f'{VAL}/out/{tg}_dn.txt')
    def cross(x,y,thr):
        i=np.where(np.diff(np.sign(y-thr))!=0)[0]; return float(np.interp(thr,y[[i[0],i[0]+1]][::-1] if y[i[0]]>y[i[0]+1] else y[[i[0],i[0]+1]],x[[i[0],i[0]+1]][::-1] if y[i[0]]>y[i[0]+1] else x[[i[0],i[0]+1]])) if len(i) else None
    vtp=cross(u['vin'],u['vout'],v/2); vtm=cross(d['vin'],d['vout'],v/2)
    hy=(vtp-vtm)*1e3 if vtp and vtm else None
    ok=bool(hy and hy>100 and u['vout'][0]>0.95*v and u['vout'][-1]<0.05*v)
    return c,dict(vt_plus=vtp,vt_minus=vtm,hyst_mv=hy,ok=ok),(u,d)
def schmitt_plot(res):
    for m in CORNERS:
        fig,ax=plt.subplots(figsize=(6.4,4.2))
        for (mm,t,v),r,(u,d) in res:
            if mm!=m: continue
            s=P.style(t,v); ax.plot(u['vin'],u['vout'],**s); ax.plot(d['vin'],d['vout'],**s)
        ax.set(xlabel='V(IN) (V)',ylabel='V(OUT) (V)')
        P.legend(ax,loc='upper right',ncol=2)
        rr=[r for (mm,_,_),r,_ in res if mm==m]
        ax.set_title(f'schmitt · mos_{m} · transferencia con histéresis · {sum(r["ok"] for r in rr)}/9 PASS',loc='left')
        P.subtitle(fig,'Histéresis (mV): '+', '.join(f'{r["hyst_mv"]:.0f}' for r in rr)+'  ·  V_T+ '+f'{min(r["vt_plus"] for r in rr):.3f}–{max(r["vt_plus"] for r in rr):.3f} V')
        P.save(fig,f'{G}/schmitt/{m}/schmitt_{m}_histeresis.png')
# ---------- comparadores ----------
def comp_job(c,cell):
    m,t,v=c; tg=tag(cell,m,t,v)
    if cell=='comp_sup':
        vref=2*v/3; inst='XC VBN VP VN OUT VDD VSS comp_sup'; fixed=f'VNN VN 0 {vref}'; sw='VPP VP 0 0'; src='VPP'
    else:
        vref=v/3; inst='XC VBP VP VN OUT VDD VSS comp_inf'; fixed=f'VPP VP 0 {vref}'; sw='VNN VN 0 0'; src='VNN'
    n=header(m,t,v,f'{cell}: barrido DC de la entrada alrededor del umbral')+cellnet('bias')+cellnet(cell)+f"""
XB VBP VBN VDD VSS bias
{inst}
VDD VDD 0 {v}
VSS VSS 0 0
{fixed}
{sw}
"""+ctl([f'dc {src} {vref-0.03:.5f} {vref+0.03:.5f} 0.05m',f'wrdata {tg}_up.txt v(vp) v(vn) v(out)',f'dc {src} {vref+0.03:.5f} {vref-0.03:.5f} -0.05m',f'wrdata {tg}_dn.txt v(vp) v(vn) v(out)'])
    run(n,tg); u=load(f'{VAL}/out/{tg}_up.txt'); d=load(f'{VAL}/out/{tg}_dn.txt')
    def trip(a):
        x=(a['vvp']-a['vvn'])*1e3; y=a['vout']; i=np.where(np.diff(np.sign(y-v/2))!=0)[0]
        if not len(i): return None
        j=i[0]; return float(x[j]+(x[j+1]-x[j])*(v/2-y[j])/(y[j+1]-y[j]))
    a,b=trip(u),trip(d)
    off=(a+b)/2 if a is not None and b is not None else None
    ok=bool(off is not None and abs(off)<10 and abs(a-b)<5 and min(u['vout'].max(),d['vout'].max())>0.95*v and max(u['vout'].min(),d['vout'].min())<0.05*v)
    return c,dict(offset_mv=off,trip_a_mv=a,trip_b_mv=b,ok=ok),(u,d)
def comp_plot(res,cell):
    for m in CORNERS:
        fig,ax=plt.subplots(figsize=(6.4,4.2))
        for (mm,t,v),r,(u,d) in res:
            if mm!=m: continue
            s=P.style(t,v)
            for a in (u,d): ax.plot((a['vvp']-a['vvn'])*1e3,a['vout'],**s)
        rr0=[r for (mm,_,_),r,_ in res if mm==m]; L=max(4,2.5*max(abs(r['offset_mv']) for r in rr0)); ax.set(xlabel='V(VP) − V(VN) (mV)',ylabel='V(OUT) (V)',xlim=(-L,L))
        P.legend(ax,loc='center right' if cell=='comp_sup' else 'center left',ncol=1)
        rr=[r for (mm,_,_),r,_ in res if mm==m]
        ref='VN = 2/3·VDD (VH)' if cell=='comp_sup' else 'VP = 1/3·VDD (VL)'
        ax.set_title(f'{cell} · mos_{m} · decisión alrededor del umbral · {sum(r["ok"] for r in rr)}/9 PASS',loc='left')
        P.subtitle(fig,f'{ref}; barrido DC en ambos sentidos. Offset de entrada (mV): '+', '.join(f'{r["offset_mv"]:+.1f}' for r in rr))
        P.save(fig,f'{G}/{cell}/{m}/{cell}_{m}_umbral.png')
if __name__=='__main__':
    import json
    R={}
    rb=pmap(bias_job,grid()); bias_plot(rb); R['bias']=[(c,r) for c,r,_ in rb]
    rs=pmap(schmitt_job,grid()); schmitt_plot(rs); R['schmitt']=[(c,r) for c,r,_ in rs]
    for cell in ['comp_sup','comp_inf']:
        rc=pmap(lambda c:comp_job(c,cell),grid()); comp_plot(rc,cell); R[cell]=[(c,r) for c,r,_ in rc]
    json.dump(R,open('/home/claude/val/res_analog.json','w'),indent=1,default=float)
    for k,v in R.items(): print(k,sum(r['ok'] for _,r in v),'/',len(v),[{kk:(round(vv,3) if isinstance(vv,float) else vv) for kk,vv in r.items()} for _,r in v][:2])
