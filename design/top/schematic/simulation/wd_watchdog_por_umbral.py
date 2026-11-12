"""wd_watchdog_por_umbral.py -- umbral de subida y de bajada del POR (rampas de 1 ms) en 45 esquinas MOS x T x R/C."""
import subprocess, itertools, re, json, os, numpy as np
from wd_sim_common import prep_netlist
net0 = prep_netlist(); os.makedirs('por_runs', exist_ok=True)
out = []
for mos, T, rc in itertools.product(['tt','ff','ss','sf','fs'], [-40, 27, 85], ['typ','wcs','bcs']):
    r, c = {'typ':('res_typ','cap_typ'),'wcs':('res_wcs','cap_wcs'),'bcs':('res_bcs','cap_bcs')}[rc]
    for var, net in [('top', net0)]:
        f = f'por_runs/p_{mos}_{T}_{rc}.sp'; o = f.replace('.sp','.dat')
        open(f,'w').write(f'''* POR: umbral de subida y de bajada con rampas lentas (1 ms)
.lib cornerMOSlv.lib mos_{mos}
.lib cornerRES.lib {r}
.lib cornerCAP.lib {c}
.include {net}
.temp {T}
.option method=gear maxord=2 reltol=1e-3
VDD VDD 0 PWL(0 0 1m 1.2 1.5m 1.2 2.5m 0)
VSS VSS 0 0
X3 POR_RAW_N VDD VSS wd_por
CPR POR_RAW_N 0 10f
.control
tran 0.2u 2.5m 0 0.5u
set wr_singlescale
wrdata {o} v(vdd) v(por_raw_n)
quit
.endc
.end
''')
        subprocess.run(['ngspice','-b',f], cwd=os.getcwd(), capture_output=True)
        d = np.loadtxt(o); t, v, p = d[:,0], d[:,1], d[:,2]
        g = p - 0.5*v
        up = (t < 1.4e-3) & (v > 0.3); dn = (t > 1.5e-3) & (v > 0.3)
        # subida: ultimo cruce hacia arriba; bajada: primer cruce hacia abajo
        iu = np.where(up[1:] & (g[:-1] <= 0) & (g[1:] > 0))[0]; idn = np.where(dn[1:] & (g[:-1] > 0) & (g[1:] <= 0))[0]
        vu = float(v[iu[-1]+1]) if len(iu) else -1; vd = float(v[idn[0]+1]) if len(idn) else -1
        out.append(dict(var=var, mos=mos, T=T, rc=rc, v_up=vu, v_down=vd))
        print(var, mos, T, rc, 'sube %.3f  baja %s' % (vu, '%.3f' % vd if vd > 0 else '< 0,30 V (no reasevera)'), flush=True)
json.dump(out, open('wd_watchdog_por_umbral.json','w'), indent=0)
ok = all(0.3 < r['v_up'] < 1.05 and r['v_down'] > 0.3 for r in out)
print('VEREDICTO:', 'PASS' if ok else 'FAIL', '(subida < 1,05 V y bajada > 0,30 V en todas las esquinas)')
