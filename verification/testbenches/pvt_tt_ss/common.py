import os,re,subprocess,json,itertools,concurrent.futures as cf
import numpy as np
PDK='/home/claude/pdk/IHP-Open-PDK/ihp-sg13g2'
MOD=PDK+'/libs.tech/ngspice/models'; SC=PDK+'/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice'
REPO='/home/claude/repo/design/blocks'
VAL='/home/claude/val'
CORNERS=['tt','ss']; TEMPS=[-40,27,85]; VDDS=[1.08,1.2,1.32]
def sympins(cell):
    import glob
    f=glob.glob(f'{REPO}/*/schematic/{cell}.sym')[0]
    return re.findall(r'^B 5 .*?\{name=(\w+)',open(f).read(),re.M)
def cellnet(cell):
    txt=open(f'{VAL}/net/{cell}.spice').read().splitlines()
    out=[]
    for l in txt:
        if l.startswith('**.subckt'):
            out.append(f'.subckt {cell} '+' '.join(sympins(cell))+' VDD VSS')
        elif l.startswith('**.ends'): out.append('.ends')
        elif l.strip().lower()=='.end': continue
        else: out.append(l)
    return '\n'.join(out)+'\n'
def header(mos,temp,vh,title):
    return f"""* {title} -- mos_{mos}, {temp} C, VDD={vh} V
.lib {MOD}/cornerMOSlv.lib mos_{mos}
.lib {MOD}/cornerRES.lib res_typ
.lib {MOD}/cornerCAP.lib cap_typ
.include {SC}
.temp {temp}
.param VH={vh}
.option method=gear maxord=2 reltol=1e-3
"""
def run(net,tag,timeout=1800):
    f=f'{VAL}/out/{tag}.sp'; open(f,'w').write(net)
    r=subprocess.run(['ngspice','-b',f],capture_output=True,text=True,timeout=timeout,cwd=f'{VAL}/out')
    log=r.stdout+r.stderr; open(f[:-3]+'.log','w').write(log)
    return log
def load(path):
    d=np.genfromtxt(path,names=True)
    return d
def grid():
    return [(m,t,v) for m in CORNERS for t in TEMPS for v in VDDS]
def pmap(fn,jobs,n=2):
    with cf.ThreadPoolExecutor(n) as ex: return list(ex.map(fn,jobs))
