"""Helpers para el barrido 'funcionamiento general' (corrientes, tiempo, flancos)."""
import sys, re, json, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))   # common.py, plot.py, gen_integracion.py
from common import *          # noqa: F401,F403  (PDK paths, header, cellnet, run, load, grid, pmap)
import plot as P
import numpy as np
import matplotlib.pyplot as plt

G = f'{VAL}/graphs'
OUT = f'{VAL}/out_func'
MET = f'{VAL}/met'
os.makedirs(OUT, exist_ok=True); os.makedirs(MET, exist_ok=True)
# paleta categórica (dataviz, orden fijo) para desgloses por bloque
CAT = ['#2a78d6', '#eb6834', '#1baf7a', '#eda100', '#e87ba4', '#008300', '#6250d6', '#e34948']


def run2(net, tag, timeout=1800):
    f = f'{OUT}/{tag}.sp'; open(f, 'w').write(net)
    r = subprocess.run(['ngspice', '-b', f], capture_output=True, text=True, timeout=timeout, cwd=OUT)
    log = r.stdout + r.stderr; open(f[:-3] + '.log', 'w').write(log)
    return log


def ld(tag):
    return np.genfromtxt(f'{OUT}/{tag}.txt', names=True)


def ctl(lines):
    return '.control\nset wr_singlescale\nset wr_vecnames\n' + '\n'.join(lines) + '\n.endc\n.end\n'


def amm(net, subckt, groups):
    """Inserta amperímetros (fuentes de 0 V) en la alimentación de instancias de un subcircuito.
    groups = {'BIAS': ['x1'], ...}. Corriente consumida por el grupo: i(v.<inst>.vam_<g>) (>0 = consume)."""
    L = net.split('\n'); out = []; inside = False
    owner = {n.lower(): g for g, ns in groups.items() for n in ns}
    for l in L:
        if l.lower().startswith('.subckt ' + subckt.lower() + ' '):
            inside = True; out.append(l)
            for g in groups: out.append(f'VAM_{g} VDD VDD_{g} 0')
            continue
        if inside and l.lower().startswith('.ends'):
            inside = False
        if inside and l.split() and l.split()[0].lower() in owner:
            g = owner[l.split()[0].lower()]
            tok = l.split(); tok = [f'VDD_{g}' if (t == 'VDD' and i > 0) else t for i, t in enumerate(tok)]
            l = ' '.join(tok)
        out.append(l)
    return '\n'.join(out)


def cross(t, y, thr, rising=True, after=None, before=None):
    s = np.sign(y - thr); d = np.diff(s)
    i = np.where(d > 0)[0] if rising else np.where(d < 0)[0]
    x = np.array([t[j] + (t[j + 1] - t[j]) * (thr - y[j]) / (y[j + 1] - y[j]) for j in i])
    if after is not None: x = x[x > after]
    if before is not None: x = x[x < before]
    return x


def first(x):
    return float(x[0]) if len(x) else np.nan


def edge_times(t, y, v, rising, after, before=None):
    """tiempos de cruce 10/50/90 % del primer flanco tras 'after'. Devuelve (t10,t50,t90)."""
    if rising:
        a = first(cross(t, y, 0.1 * v, True, after, before)); b = first(cross(t, y, 0.5 * v, True, after, before)); c = first(cross(t, y, 0.9 * v, True, after, before))
    else:
        a = first(cross(t, y, 0.9 * v, False, after, before)); b = first(cross(t, y, 0.5 * v, False, after, before)); c = first(cross(t, y, 0.1 * v, False, after, before))
    return a, b, c


def avg(t, y, a, b):
    k = (t >= a) & (t <= b)
    return float(np.trapezoid(y[k], t[k]) / (t[k][-1] - t[k][0]))


def integ(t, y, a, b):
    k = (t >= a) & (t <= b)
    return float(np.trapezoid(y[k], t[k]))


def bk_pwl(edges, pre=1e-9, post=3e-9, dt=25e-12):
    """VBK: puntos de quiebre cada dt alrededor de flancos conocidos (sin efecto eléctrico)."""
    pts = ['0 0']; s = 0; last = -1
    for e in sorted(edges):
        for j in range(-int(pre / dt), int(post / dt) + 1):
            tt = e + j * dt
            if tt <= last + 1e-15: continue
            s = 1e-3 - s; pts.append(f'{tt:.13g} {s:.3g}'); last = tt
    return '\n+ '.join(' '.join(pts[i:i + 8]) for i in range(0, len(pts), 8))


def save_met(cell, data):
    json.dump(data, open(f'{MET}/{cell}.json', 'w'), indent=1, default=float)


def cond_label(t, v):
    return f'{t} °C\n{v:.2f} V'.replace('.', ',')


def sci(x, nd=2):
    return f'{x:.{nd}f}'.replace('.', ',')


def suptitle(fig, txt, y=1.0, x=0.01):
    fig.suptitle(txt, x=x, y=y, ha='left', fontsize=11, fontweight='bold')
