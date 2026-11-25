"""f0_resistores.py -- F0 de layout: verifica que el plegado propuesto de los resistores no cambia el circuito.
Correr desde design/top/schematic/simulation/ en IIC-OSIC-TOOLS (el .spiceinit del PDK resuelve .lib y OSDI).
  python3 ../../../../verification/layout_prep/f0_resistores.py [--rapido]
Variantes (se generan desde wd_watchdog.spice):
  v1    : esquematico v1.0
  D     : propuesta (RT plegado exacto b=99; resto en unidades serie b=0 que LVS suma)
  naive : RT replegado sin corregir l (l = 16*661/100): control que debe FALLAR (T +1 %)
Salida: f0_resultados.json y VEREDICTO."""
import subprocess, itertools, json, os, re, sys, numpy as np
from concurrent.futures import ThreadPoolExecutor
NET = os.environ.get('WD_NET', 'wd_watchdog.spice'); RAPIDO = '--rapido' in sys.argv
os.makedirs('f0_runs', exist_ok=True)
src = open(NET).read().splitlines(); i0 = next(i for i, l in enumerate(src) if l.startswith('**.ends')) + 1
base = '\n'.join(src[i0:]); base = re.sub(r'\n\.end\s*$', '\n', base)
RT_NEW = 'XR4 VC DRIVE VSS rppd w=1e-6 l=104.70e-6 m=1 b=99 mm_ok=1'   # RT ya cambiado en el esquematico (0001)
def chain(name, a, b, model, w, l, n):
    out, prev = [], a
    for i in range(n):
        nx = b if i == n - 1 else f'{name}_n{i}'
        out.append(f'{name}_{i} {prev} {nx} VSS {model} w={w} l={l} m=1 b=0'); prev = nx
    return '\n'.join(out)
UNITS = [('XR1 VDD VH VSS rhigh w=1e-6 l=450.0e-6 m=1 b=0 mm_ok=1', chain('XR1', 'VDD', 'VH', 'rhigh', '1e-6', '45e-6', 10)),
         ('XR2 VH VL VSS rhigh w=1e-6 l=450.0e-6 m=1 b=0 mm_ok=1', chain('XR2', 'VH', 'VL', 'rhigh', '1e-6', '45e-6', 10)),
         ('XR3 VL VSS VSS rhigh w=1e-6 l=450.0e-6 m=1 b=0 mm_ok=1', chain('XR3', 'VL', 'VSS', 'rhigh', '1e-6', '45e-6', 10)),
         ('XR1 VDD VD VSS rhigh w=0.5e-6 l=320e-6 m=1 b=0 mm_ok=1', chain('XR1', 'VDD', 'VD', 'rhigh', '0.5e-6', '32e-6', 10)),
         ('XR2 VD VSS VSS rhigh w=0.5e-6 l=385e-6 m=1 b=0 mm_ok=1', chain('XR2', 'VD', 'VSS', 'rhigh', '0.5e-6', '35e-6', 11)),
         ('XR4 VDD X VSS rhigh w=0.5e-6 l=675e-6 m=1 b=0 mm_ok=1', chain('XR4', 'VDD', 'X', 'rhigh', '0.5e-6', '25e-6', 27)),
         ('XR1 VDD VBN VSS rhigh w=0.5e-6 l=237.0e-6 m=1 b=0 mm_ok=1', chain('XR1B', 'VDD', 'VBN', 'rhigh', '0.5e-6', '29.625e-6', 8))]
RT0 = 'XR4 VC DRIVE VSS rppd w=1e-6 l=661e-6 m=1 b=15 mm_ok=1'
base = base.replace(RT_NEW, RT0)   # v1 = esquematico v1.0 aunque el netlist ya tenga el RT nuevo
def variant(rt):
    s = base
    for a, b in UNITS:
        assert a in s, 'no encontrado en el netlist: ' + a; s = s.replace(a, b)
    assert RT0 in s; return s.replace(RT0, rt)
libs = {'v1': base, 'D': variant('XR4 VC DRIVE VSS rppd w=1e-6 l=104.70e-6 m=1 b=99'),
        'naive': variant('XR4 VC DRIVE VSS rppd w=1e-6 l=105.76e-6 m=1 b=99')}
for k, s in libs.items(): open(f'f0_runs/lib_{k}.spice', 'w').write(s)
RC = {'typ': ('res_typ', 'cap_typ'), 'wcs': ('res_wcs', 'cap_wcs'), 'bcs': ('res_bcs', 'cap_bcs')}
def osc(case):
    var, mos, T, V, rc = case
    for tm in ('0.1u', '0.07u', '0.13u'):
        tag = f'osc_{var}_{mos}_{T}_{V}_{rc}'; f = f'f0_runs/{tag}.sp'
        open(f, 'w').write(f'''* {tag}
.lib cornerMOSlv.lib mos_{mos}
.lib cornerRES.lib {RC[rc][0]}
.lib cornerCAP.lib {RC[rc][1]}
.include lib_{var}.spice
.temp {T}
.option method=gear maxord=2 reltol=1e-3
Vsup VDD 0 PWL(0 0 10u {V})
Vgnd VSS 0 0
x1 CLK VDD VSS wd_oscillater
.save v(x1.vc) v(clk)
.control
tran 0.2u 0.7m 0 {tm}
let vm={V}/2
meas tran tvc TRIG v(x1.vc) VAL=vm TD=0.25m RISE=1 TARG v(x1.vc) VAL=vm TD=0.25m RISE=4
meas tran tck TRIG v(clk) VAL=vm TD=0.25m RISE=1 TARG v(clk) VAL=vm TD=0.25m RISE=4
echo RES $&tvc $&tck
quit
.endc
.end
''')
        out = subprocess.run(['ngspice', '-b', os.path.basename(f)], cwd='f0_runs', capture_output=True, text=True).stdout
        m = re.search(r'RES ([-\d.e+]+) ([-\d.e+]+)', out)
        if m:
            tvc, tck = map(float, m.groups())
            if tvc > 0 and abs(tck - tvc) / tvc < 0.01: return dict(kind='osc', var=var, mos=mos, T=T, V=V, rc=rc, T_us=tvc / 3e-6, tmax=tm)
    return dict(kind='osc', var=var, mos=mos, T=T, V=V, rc=rc, T_us=None)
def por(case):
    var, mos, T, rc = case; tag = f'por_{var}_{mos}_{T}_{rc}'; f = f'f0_runs/{tag}.sp'; o = f'{tag}.dat'
    open(f, 'w').write(f'''* {tag}
.lib cornerMOSlv.lib mos_{mos}
.lib cornerRES.lib {RC[rc][0]}
.lib cornerCAP.lib {RC[rc][1]}
.include lib_{var}.spice
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
    subprocess.run(['ngspice', '-b', os.path.basename(f)], cwd='f0_runs', capture_output=True)
    d = np.loadtxt('f0_runs/' + o); t, v, p = d[:, 0], d[:, 1], d[:, 2]; g = p - 0.5 * v
    up = (t < 1.4e-3) & (v > 0.3); dn = (t > 1.5e-3) & (v > 0.3)
    iu = np.where(up[1:] & (g[:-1] <= 0) & (g[1:] > 0))[0]; idn = np.where(dn[1:] & (g[:-1] > 0) & (g[1:] <= 0))[0]
    return dict(kind='por', var=var, mos=mos, T=T, rc=rc, v_up=float(v[iu[-1] + 1]) if len(iu) else -1, v_down=float(v[idn[0] + 1]) if len(idn) else -1)
MOS = ('tt',) if RAPIDO else ('tt', 'ff', 'ss', 'sf', 'fs'); TS = (-40, 27, 85); VS = (1.08, 1.2, 1.32)
oc = [(v, m, T, V, 'typ') for v in ('v1', 'D') for m in MOS for T in TS for V in VS]
oc += [(v, 'tt', T, 1.2, rc) for v in ('v1', 'D') for T in TS for rc in ('wcs', 'bcs')]
oc += [('naive', 'tt', T, 1.2, 'typ') for T in TS]
pc = [(v, m, T, rc) for v in ('v1', 'D') for m in MOS for T in TS for rc in ('typ', 'wcs', 'bcs')]
res = []
with ThreadPoolExecutor(int(os.environ.get('WD_JOBS', '2'))) as ex:
    for r in list(ex.map(osc, oc)) + list(ex.map(por, pc)): res.append(r); print(r, flush=True)
json.dump(res, open('f0_resultados.json', 'w'), indent=0)
O = {(r['var'], r['mos'], r['T'], r['V'], r['rc']): r['T_us'] for r in res if r['kind'] == 'osc'}
P = {(r['var'], r['mos'], r['T'], r['rc']): r for r in res if r['kind'] == 'por'}
dD = [(O[k] / O[('v1',) + k[1:]] - 1) * 100 for k in O if k[0] == 'D']
dN = [(O[k] / O[('v1',) + k[1:]] - 1) * 100 for k in O if k[0] == 'naive']
du = [(P[k]['v_up'] - P[('v1',) + k[1:]]['v_up']) * 1e3 for k in P if k[0] == 'D']
okD = all(abs(x) < 0.5 for x in dD) and abs(np.mean(dD)) < 0.1      # ruido numerico del latch: +-0,35 %
okN = all(x > 0.6 for x in dN)                                       # el control debe detectar el +1 % (R naive +1,0 %)
okP = all(abs(x) < 5 for x in du) and all(0.3 < P[k]['v_up'] < 1.05 and P[k]['v_down'] > 0.3 for k in P)
print(f'osc D vs v1: {min(dD):+.3f}..{max(dD):+.3f} % (media {np.mean(dD):+.3f} %) | naive: {min(dN):+.2f}..{max(dN):+.2f} %')
print(f'POR D vs v1: subida {min(du):+.1f}..{max(du):+.1f} mV')
print('VEREDICTO:', 'PASS' if okD and okN and okP else 'FAIL', f'(osc={okD}, control_naive_detectado={okN}, por={okP})')
