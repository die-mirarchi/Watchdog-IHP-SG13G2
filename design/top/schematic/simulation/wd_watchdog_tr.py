#!/usr/bin/env python3
"""wd_watchdog_tr.py -- top completo a nivel transistor (tt, 25 C, 1,2 V): toda la logica (wd_reset_sync,
WDI_INPUT, wd_digital con el contador de 17 bits) + wd_por, con CLK de flancos resueltos a 50 MHz y tmax 0,5 ns.
La logica es sincronica: el periodo del reloj solo comprime el tiempo (1 ciclo = 1 T = 97,66 us en el chip).
Escenario (SET = 01): encendido -> WDI (sale de arranque) -> WDI (borra) -> timeout de 1025 T -> pulso de 1025 T
(con un WDI en el medio, ignorado) -> modo arranque -> WDI. Compara ciclo a ciclo contra el modelo de referencia.
El oscilador y el POR en tiempo real se verifican con wd_watchdog_tb.sch / wd_watchdog_pvt.py: con el CLK del
oscilador libre, ngspice + PSP/OSDI resuelve el flanco en un paso y los FF pueden capturar mal (artefacto).
Uso (en simulation/, con wd_watchdog.spice exportado): python3 wd_watchdog_tr.py"""
"""Top a nivel transistor (tt, 25 C, 1,2 V), logica completa + POR, reloj de 50 MHz con flancos de 0,2 ns y
tmax 0,5 ns (como counter17_tb, que corre a 50 MHz). La logica es sincronica: el periodo no
cambia la cuenta, solo comprime el tiempo (cada ciclo = 1 T = 97,66 us en el chip)."""
import sys, json, os, subprocess
import numpy as np
from wd_sim_common import prep_netlist, xings
TC = 20e-9; T0 = 5e-6          # periodo y primer flanco de subida (VDD en rampa de 10 us)
V = 1.2
def rise(c): return T0 + c * TC
W = []                            # (ciclo de inicio, ancho en ciclos) de los pulsos de WDI (a mitad de ciclo)
W = [(60, 10), (400, 10), (1900, 10), (2470, 10)]
NC = 2490
pw = ['0 0']
for c, n in W:
    a = rise(c) + 0.5 * TC; b = rise(c + n) + 0.5 * TC
    pw += [f'{a:.12g} 0', f'{a + 0.2e-9:.12g} {V}', f'{b:.12g} {V}', f'{b + 0.2e-9:.12g} 0']
tend = rise(NC)
Q = ' '.join(f'v(x5.x2.q{i})' for i in range(10)) + ' v(x5.net4) ' + ' '.join(f'v(x5.x2.q{i})' for i in range(11, 17))
SIG = f'v(vdd) v(clk) v(por_raw_n) v(por_b) v(wdi_in) v(edge) v(boot) v(active) v(reset_out) v(x5.net5) v(x2.p1) v(x4.wdi_meta) v(x4.wdi_sync) v(q_sync) v(q_por) v(q_wdi) v(q_dig) {Q}'
NET = prep_netlist()
s = f'''* top a nivel transistor, logica + POR, reloj 50 MHz (ciclo = 1 T)
.lib cornerMOSlv.lib mos_tt
.lib cornerRES.lib res_typ
.lib cornerCAP.lib cap_typ
.include {NET}
.temp 25
.option method=gear maxord=2 reltol=1e-3
VDD VDD 0 PWL(0 0 10u {V})
VSS VSS 0 0
VS1 SET1 0 0
VS0 SET0 0 {V}
VW WDI_IN 0 PWL({' '.join(pw)})
VSCLK SCLK 0 PULSE(0 1 {T0 - 0.1e-9:.12g} 0.1n 0.1n {TC/2 - 0.1e-9:.12g} {TC:.12g})
RSCLK SCLK 0 1k
BCLK CLK 0 V=v(VDD)*v(SCLK)
CCLK CLK 0 20f
VAM_sync VDD VDD_sync 0
X2 POR_RAW_N CLK POR_B VDD_sync VSS wd_reset_sync
VAM_por VDD VDD_por 0
X3 POR_RAW_N VDD_por VSS wd_por
VAM_wdi VDD VDD_wdi 0
X4 POR_B CLK WDI_IN EDGE VDD_wdi VSS WDI_INPUT
VAM_dig VDD VDD_dig 0
X5 RESET_OUT BOOT CLK EDGE ACTIVE POR_B SET1 SET0 VDD_dig VSS wd_digital
CL RESET_OUT 0 100f
'''
for b in ['sync', 'por', 'wdi', 'dig']:
    s += f'BQ_{b} 0 Q_{b} I=i(VAM_{b})*(time>0)\nRQ_{b} Q_{b} 0 1e15\nCQ_{b} Q_{b} 0 1e-8\n'
s += f'''.save {SIG}
.control
tran 0.1n {tend:.9g} 0 0.5n
set wr_singlescale
set wr_vecnames
wrdata wd_watchdog_tr.dat {SIG}
quit
.endc
.end
'''
open('wd_watchdog_tr.sp', 'w').write(s)
if '--solo-netlist' not in sys.argv:
    print('corriendo ngspice (~1 h)...', flush=True)
    subprocess.run(['ngspice', '-b', 'wd_watchdog_tr.sp'], stdout=open('wd_watchdog_tr.log', 'w'), stderr=subprocess.STDOUT)

# ---------------- modelo de referencia ----------------
def golden_run(rises, t_por_rel, wdi_fn, set1, set0):
    """rises: tiempos de flancos de subida de CLK; t_por_rel: liberacion de POR_RAW_N; wdi_fn(t) -> 0/1
    devuelve lista de estados DESPUES de cada flanco (dict)."""
    p1 = porb = meta = sync = hist = rs = nb = 0; cnt = 0
    c0, c1 = set0, set1
    out = []
    for t in rises:
        if t < t_por_rel:
            out.append(dict(t=t, porb=0, rs=0, nb=0, cnt=0, out=0, act=1 - (c0 & c1), boot=1)); continue
        if not porb: c0, c1 = set0, set1          # latch transparente
        edge = sync & (1 - hist)
        dis = c0 & c1; act = 1 - (dis | rs)
        t01 = (cnt >> 10) & 1; t00 = ((cnt >> 13) & 1) & ((cnt >> 11) & 1); t10 = ((cnt >> 16) & 1) & ((cnt >> 15) & 1) & ((cnt >> 12) & 1)
        ton = [t00, t01, t10, 0][c1 * 2 + c0]
        to = ton if nb else t10
        hit = act & to & (1 - edge)
        clr = t01 if rs else (dis | edge | hit)
        w = wdi_fn(t)
        if porb:
            meta, sync, hist = w, meta, sync
            rs, nb = hit | (rs & (1 - t01)), (nb | (edge & act)) & (1 - rs)
            cnt = 0 if clr else (cnt + 1) & 0x1FFFF
        p1, porb = 1, p1
        dis = c0 & c1; act = 1 - (dis | rs)
        out.append(dict(t=t, porb=porb, rs=rs, nb=nb, cnt=cnt, out=porb & rs, act=act, boot=1 - nb))
    return out

# ---------------- analisis ----------------
fn = 'wd_watchdog_tr.dat'
S = dict(TC=TC, T0=T0, NC=NC)
d = np.genfromtxt(fn, names=True); t = d['time']
V = d['vvdd']
qn = ['vx5x2q%d' % i for i in range(10)] + ['vx5net4'] + ['vx5x2q%d' % i for i in range(11, 17)]
rises = np.array([T0 + k * TC for k in range(S['NC'] + 1) if T0 + k * TC < t[-1] - TC])
prel = xings(t, d['vpor_raw_n'] - 0.5 * V); prel = prel[np.interp(prel, t, V) > 0.3][0]
wt = xings(t, d['vwdi_in'] - 0.6); wf = xings(t, d['vwdi_in'] - 0.6, rise=False)
def wfn(x): return int(any((a < x < b) for a, b in zip(wt, wf)))
G = golden_run(rises, prel, wfn, 0, 1)
def s(n, x): return int(np.interp(x, t, d[n]) > 0.6)
nm = 0; first = []; cnt = []
for k, g in enumerate(G[:-1]):
    ts = rises[k + 1] - 0.25 * TC
    c = sum(s(q, ts) << i for i, q in enumerate(qn)); cnt.append(c)
    o = dict(porb=s('vpor_b', ts), out=s('vreset_out', ts), boot=s('vboot', ts), act=s('vactive', ts), cnt=c)
    ok = o['porb'] == g['porb'] and o['out'] == g['out'] and o['boot'] == g['boot'] and o['cnt'] == g['cnt'] and (g['porb'] == 0 or o['act'] == g['act'])
    if not ok:
        nm += 1
        if len(first) < 5: first.append((k, o, {kk: g[kk] for kk in ('porb', 'out', 'boot', 'act', 'cnt')}))
ro = xings(t, d['vreset_out'] - 0.6); rf = xings(t, d['vreset_out'] - 0.6, rise=False)
cyc = lambda x: (x - T0) / TC
R = dict(ciclos=len(G) - 1, diferencias=nm, primeras=first, por_rel_ciclo=cyc(prel), vdd_por=float(np.interp(prel, t, V)),
         wdi_sube_ciclo=[round(cyc(x), 2) for x in wt], reset_sube_ciclo=[round(cyc(x), 2) for x in ro], reset_baja_ciclo=[round(cyc(x), 2) for x in rf],
         boot_baja=[round(cyc(x), 2) for x in xings(t, d['vboot'] - 0.6, rise=False)], boot_sube=[round(cyc(x), 2) for x in xings(t, d['vboot'] - 0.6)],
         porb_sube=[round(cyc(x), 2) for x in xings(t, d['vpor_b'] - 0.6)])
if len(ro) and len(rf): R['pulso_ciclos'] = round(cyc(rf[0]) - cyc(ro[0]), 3)
if len(ro): R['timeout_desde_wdi_ciclos'] = round(cyc(ro[0]) - cyc(wt[1]), 3)
# consumo: carga por ciclo en la ventana estable (despues de la rampa), integradores V(Q) = Q / 10 nF
for b in ['sync', 'por', 'wdi', 'dig']:
    q = d['vq_' + b] * 1e-8
    i0, i1 = np.searchsorted(t, [rises[600], rises[1300]])
    dq = q[i1] - q[i0]; n = 700
    R['q_ciclo_fC_' + b] = dq / n * 1e15
# salida: tiempos de flanco de RESET_OUT (10-90 %) y retardo desde CLK
if len(ro):
    k = np.argmin(np.abs(rises - ro[0])); R['reset_out_retardo_clk_ps'] = (ro[0] - rises[k]) * 1e12
json.dump(R, open('wd_watchdog_tr.json', 'w'), indent=1, default=float)
ok = R['diferencias'] == 0 and R.get('pulso_ciclos', 0) > 1024.5 and R.get('pulso_ciclos', 0) < 1025.5
print('VEREDICTO:', 'PASS' if ok else 'FAIL')
print(json.dumps(R, indent=1, default=float)[:3000])

