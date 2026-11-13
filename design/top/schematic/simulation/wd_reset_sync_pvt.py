#!/usr/bin/env python3
"""wd_reset_sync_pvt.py -- retardo de POR (wd_reset_sync v2: 2 FF + contador de 5 bits) + wd_por a nivel transistor en PVT.
CLK ideal de 20 MHz (flancos 0,1 ns) y tmax 0,5 ns: el retardo se mide en flancos, asi que el tiempo se puede comprimir
(con tmax mayores o CLK lento ngspice da artefactos en los FF). Perfil de VDD: rampa de 2 us; caida a 0,3 V de 10 us en 8 us
(POR_B ya en 1); segunda caida de 10 us 0,8 us despues de la re-liberacion (durante la cuenta; el instante se ubica con una
corrida previa del POR solo); fin 3 us despues de la ultima liberacion.
PASS por esquina: sin aborto; POR_B sube 34 (o 35, si la liberacion cae sobre un flanco) flancos despues de cada liberacion
de POR_RAW_N; la caida con POR_B = 1 lo baja (< 0,1 V); la caida durante la cuenta reinicia el retardo.
Uso (desde simulation/, IIC-OSIC-TOOLS):  NPROC=2 python3 wd_reset_sync_pvt.py  [mos T V]  -> wd_reset_sync_pvt.jsonl"""
import sys, os, json, itertools, subprocess, numpy as np
from multiprocessing import Pool
from wd_sim_common import prep_netlist, xings
RUNDIR = os.getcwd(); TC = 50e-9; T0 = 0.25e-6
HDR = lambda net, mos, T: (f'.lib cornerMOSlv.lib mos_{mos}\n.lib cornerRES.lib res_typ\n.lib cornerCAP.lib cap_typ\n'
                           f'.include {net}\n.temp {T}\n.option method=gear maxord=2 reltol=1e-3\n')
def pwl(V, d2=None):
    p = f'0 0 2u {V} 8u {V} 8.1u 0.3 18.1u 0.3 18.2u {V}'
    if d2: p += f' {d2:.9g} {V} {d2 + 0.1e-6:.9g} 0.3 {d2 + 10.1e-6:.9g} 0.3 {d2 + 10.2e-6:.9g} {V}'
    return p
def run(f, txt):
    open(f, 'w').write(txt)
    p = subprocess.run(['ngspice', '-b', f], cwd=RUNDIR, capture_output=True, text=True)
    return 'Timestep too small' in p.stdout + p.stderr
def one(job):
    net, mos, T, V = job; k = f'{mos}_{T}_{V}'; os.makedirs('sync_runs', exist_ok=True)
    f = f'sync_runs/p_{k}.sp'; o = f.replace('.sp', '.dat')
    for tmp in ['50n', '30n', '70n', '20n', '10n']:           # 1) POR solo: re-liberacion tras la primera caida
        ab0 = run(f, f'* POR solo\n{HDR(net, mos, T)}VDD VDD 0 PWL({pwl(V)})\nVSS VSS 0 0\nX3 POR_RAW_N VDD VSS wd_por\nCPR POR_RAW_N 0 10f\n'
                     f'.control\ntran 0.05u 35u 0 {tmp}\nset wr_singlescale\nwrdata {o} v(vdd) v(por_raw_n)\nquit\n.endc\n.end\n')
        d = np.loadtxt(o); r = xings(d[:, 0], d[:, 2] - 0.5 * d[:, 1]); r = r[r > 18.2e-6]
        if not ab0 and len(r): break
    d2 = r[0] + 0.8e-6; tend = d2 + 10.2e-6 + (r[0] - 18.2e-6) + 3e-6
    f = f'sync_runs/s_{k}.sp'; o = f.replace('.sp', '.dat')
    for tm in ['0.5n', '0.4n', '0.6n']:                        # 2) POR + sincronizador
        ab = run(f, f'''* wd_reset_sync v2 + wd_por
{HDR(net, mos, T)}VDD VDD 0 PWL({pwl(V, d2)})
VSS VSS 0 0
VSCLK SCLK 0 PULSE(0 1 {T0:.12g} 0.1n 0.1n {TC/2 - 0.1e-9:.12g} {TC:.12g})
RSCLK SCLK 0 1k
BCLK CLK 0 V=v(VDD)*v(SCLK)
CCLK CLK 0 20f
X3 POR_RAW_N VDD VSS wd_por
X2 POR_RAW_N CLK POR_B VDD VSS wd_reset_sync
CPB POR_B 0 100f
.control
tran 0.1n {tend:.9g} 0 {tm}
set wr_singlescale
set wr_vecnames
wrdata {o} v(vdd) v(clk) v(por_raw_n) v(por_b) v(x2.sync) v(x2.d4)
quit
.endc
.end
''')
        d = np.genfromtxt(o, names=True); t = d['time']
        if not ab and t[-1] > tend * 0.999: break
    v = d['vvdd']
    rel = xings(t, d['vpor_raw_n'] - 0.5 * v); rel = rel[np.interp(rel, t, v) > 0.5]
    pbr = xings(t, d['vpor_b'] - 0.5 * v); pbr = pbr[np.interp(pbr, t, v) > 0.35]
    edges = np.array([T0 + j * TC for j in range(int(tend / TC) + 2)])
    n = [int(np.sum((edges > rel[rel < x][-1]) & (edges <= x + 1e-9))) for x in pbr]
    rd = rel[(rel > 18.2e-6) & (rel < d2)]
    cuenta = bool(len(rd) and not np.any((pbr > rd[-1]) & (pbr < d2 + 0.1e-6)))
    pb_antes = float(d['vpor_b'][np.searchsorted(t, 7.9e-6)]); pb_tras = float(d['vpor_b'][np.searchsorted(t, 18.4e-6)])
    R = dict(mos=mos, T=T, V=V, tmax=tm, aborto=ab, flancos=n, caida_en_cuenta=cuenta, porb_antes_caida1=pb_antes,
             porb_tras_caida1=pb_tras, rel_us=[round(x * 1e6, 3) for x in rel], porb_us=[round(x * 1e6, 3) for x in pbr])
    R['pass'] = bool(not ab and len(n) == 2 and all(x in (34, 35) for x in n) and cuenta and pb_antes > 0.8 * V and pb_tras < 0.1)
    return R
if __name__ == '__main__':
    net = prep_netlist()
    J = list(itertools.product(['tt', 'ss', 'ff', 'sf', 'fs'], [-40, 27, 85], [1.08])) + [(m, 27, 1.32) for m in ['tt', 'ss', 'ff']]
    if len(sys.argv) > 3: J = [(sys.argv[1], int(sys.argv[2]), float(sys.argv[3]))]
    out = open('wd_reset_sync_pvt.jsonl', 'w'); npass = 0
    with Pool(int(os.environ.get('NPROC', '1'))) as p:
        for R in p.imap_unordered(one, [(net,) + j for j in J]):
            out.write(json.dumps(R) + '\n'); out.flush(); npass += R['pass']
            print(R['mos'], R['T'], R['V'], 'PASS' if R['pass'] else 'FAIL', R['flancos'], R['caida_en_cuenta'], flush=True)
    print(f'VEREDICTO: {npass}/{len(J)} PASS', 'PASS' if npass == len(J) else 'FAIL')
