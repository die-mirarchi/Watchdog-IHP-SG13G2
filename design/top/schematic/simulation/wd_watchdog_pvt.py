#!/usr/bin/env python3
"""wd_watchdog_pvt.py -- analogico del top en PVT: wd_oscillater (con bias) + wd_por a nivel transistor, con la carga real
de la logica en CLK (120 fF) y POR_RAW_N (10 fF). Sin FF (sus artefactos con el reloj del oscilador se evitan;
la logica se verifica aparte). Se mide el 2.o flanco de CLK tras POR_RAW_N (SYNC de wd_reset_sync); con el retardo de
wd_reset_sync v2, POR_B sube 32 flancos despues (verificado en wd_reset_sync_pvt.py). Perfil: rampa 0 -> V en 1 ms; caida a 0,40 V (2,00-2,07 ms); fin 2,8 ms."""
import sys, os, subprocess, json, itertools, numpy as np
from multiprocessing import Pool
RUNDIR = os.getcwd()
from wd_sim_common import prep_netlist, xings as _x
TMAX = ['70n', '100n', '50n', '130n', '85n', '60n', '110n', '40n']
def tb(net, mos, T, V, rc, tmax, out):
    r, c = {'typ': ('res_typ', 'cap_typ'), 'wcs': ('res_wcs', 'cap_wcs'), 'bcs': ('res_bcs', 'cap_bcs')}[rc]
    return f'''* analogico del top {mos} {T} {V} {rc}
.lib cornerMOSlv.lib mos_{mos}
.lib cornerRES.lib {r}
.lib cornerCAP.lib {c}
.include {net}
.temp {T}
.option method=gear maxord=2 reltol=1e-3
VDD VDD 0 PWL(0 0 1m {V} 2m {V} 2.01m 0.4 2.06m 0.4 2.07m {V})
VSS VSS 0 0
VAMO VDD VDDO 0
X1 CLK VDDO VSS wd_oscillater
VAMP VDD VDDP 0
X3 POR_RAW_N VDDP VSS wd_por
CCLK CLK 0 120f
CPR POR_RAW_N 0 10f
.control
tran 0.1u 2.8m 0 {tmax}
set wr_singlescale
set wr_vecnames
wrdata {out} v(vdd) v(clk) v(por_raw_n) v(x1.vc) i(vamo) i(vamp)
quit
.endc
.end
'''
def xings(t, v, th=0.0, rise=True):
    a, b = v[:-1], v[1:]
    i = np.where((a <= th) & (b > th))[0] if rise else np.where((a >= th) & (b < th))[0]
    return t[i] + (th - a[i]) / (b[i] - a[i]) * (t[i + 1] - t[i])
def analyze(f, V, rc):
    d = np.genfromtxt(f, names=True)
    t = d['time']; vdd = d['vvdd']; clk = d['vclk']; prn = d['vpor_raw_n']; vc = d['vx1vc']
    io = d['ivamo']; ip = d['ivamp']
    R = {}
    g = (prn - 0.5 * vdd) * (vdd > 0.3) - 0.01 * (vdd <= 0.3)
    m = t < 1.95e-3
    tr = xings(t[m], g[m])
    R['t_rel_us'] = float(tr[-1] * 1e6) if len(tr) else -1
    R['vrel'] = float(np.interp(tr[-1], t, vdd)) if len(tr) else -1
    R['por_glitches'] = int(max(0, len(tr) - 1))
    ce = xings(t, clk - 0.5 * vdd); ce = ce[np.interp(ce, t, vdd) > 0.3]
    R['vdd_clk_first'] = float(np.interp(ce[0], t, vdd)) if len(ce) else -1
    if len(tr):
        e = ce[(ce > tr[-1]) & (ce < 1.98e-3)]
        R['t_porb_us'] = float(e[1] * 1e6) if len(e) > 1 else -1
        R['porb_delay_us'] = float((e[1] - tr[-1]) * 1e6) if len(e) > 1 else -1
        R['vdd_porb'] = float(np.interp(e[1], t, vdd)) if len(e) > 1 else -1
    vx = xings(t, vc - 0.5 * vdd); vx = vx[(vx > 1.15e-3) & (vx < 1.98e-3)]
    R['T_us'] = float(np.mean(np.diff(vx)) * 1e6) if len(vx) > 2 else -1
    R['T_err_pct'] = 100 * (R['T_us'] - 97.656) / 97.656 if R['T_us'] > 0 else -999
    w = ce[(ce > 1.15e-3) & (ce < 1.98e-3)]
    if len(w) > 1:
        cf = xings(t, clk - 0.5 * vdd, rise=False); cf = cf[(cf > w[0]) & (cf < w[1])]
        R['duty_pct'] = float(100 * (cf[0] - w[0]) / (w[1] - w[0])) if len(cf) else -1
    if len(w) > 4:
        mm = (t >= w[0]) & (t <= w[4])
        R['i_osc_uA'] = float(np.trapezoid(io[mm], t[mm]) / (t[mm][-1] - t[mm][0]) * 1e6)
        R['i_por_uA'] = float(np.trapezoid(ip[mm], t[mm]) / (t[mm][-1] - t[mm][0]) * 1e6)
    md = (t > 2.03e-3) & (t < 2.06e-3)
    R['dip_por_raw_n_max'] = float(prn[md].max())
    r2 = xings(t, prn - 0.5 * vdd); r2 = r2[r2 > 2.055e-3]
    R['t_rel2_us'] = float((r2[0] - 2.06e-3) * 1e6) if len(r2) else -1
    c2 = ce[ce > 2.07e-3]
    R['clk_after_dip'] = int(len(c2))
    lim = 5.0 if rc == 'typ' else 30.0
    R['pass'] = bool(0.3 < R['vrel'] < 1.05 and R.get('t_porb_us', -1) > 0 and abs(R['T_err_pct']) < lim
                     and R['dip_por_raw_n_max'] < 0.2 and R['t_rel2_us'] > 0 and R['clk_after_dip'] >= 3 and R['por_glitches'] == 0)
    return R
def one(job):
    var, net, mos, T, V, rc = job
    key = f'{var}_{mos}_{T}_{V}_{rc}'
    for k, tm in enumerate(TMAX):
        f = f'pvt_runs/{key}.sp'; o = f'pvt_runs/{key}.dat'
        if os.path.exists(o): os.remove(o)
        open(f, 'w').write(tb(net, mos, T, V, rc, tm, o))
        p = subprocess.run(['ngspice', '-b', f], cwd=RUNDIR, capture_output=True, text=True)
        if 'Timestep too small' not in p.stdout + p.stderr and os.path.exists(o):
            R = analyze(o, V, rc); R.update(var=var, mos=mos, T=T, V=V, rc=rc, tmax=tm, tries=k + 1)
            return R
    return {'var': var, 'mos': mos, 'T': T, 'V': V, 'rc': rc, 'err': 'no converge', 'pass': False}
if __name__ == '__main__':
    # uso: python3 wd_watchdog_pvt.py   (en simulation/, con wd_watchdog.spice exportado; NPROC=2 para 2 procesos)
    os.makedirs('pvt_runs', exist_ok=True)
    net = prep_netlist()
    jobs = [('top', net, m, T, V, 'typ') for m, T, V in itertools.product(['tt', 'ff', 'ss', 'sf', 'fs'], [-40, 27, 85], [1.08, 1.2, 1.32])]
    jobs += [('top', net, m, T, 1.08, rc) for m, T, rc in [('tt', -40, 'wcs'), ('tt', 85, 'wcs'), ('tt', -40, 'bcs'), ('tt', 85, 'bcs'),
                                                            ('ss', 85, 'bcs'), ('ss', -40, 'bcs'), ('ff', -40, 'wcs'), ('ff', 85, 'wcs')]]
    out = open('wd_watchdog_pvt.jsonl', 'w'); n = 0
    with Pool(int(os.environ.get('NPROC', '1'))) as pool:
        for R in pool.imap_unordered(one, jobs):
            out.write(json.dumps(R) + '\n'); out.flush(); n += R['pass']
            print(R['mos'], R['T'], R['V'], R['rc'], 'PASS' if R['pass'] else 'FAIL', 'vrel=%.3f T=%.2f' % (R.get('vrel', -1), R.get('T_us', -1)), flush=True)
    print(f'VEREDICTO: {"PASS" if n == len(jobs) else "FAIL"} ({n}/{len(jobs)})')
