"""Utilidades comunes de los bancos del top (ngspice). Correr desde simulation/ en IIC-OSIC-TOOLS:
el .spiceinit del PDK resuelve los .lib y los modelos OSDI."""
import os, numpy as np
NET = os.environ.get('WD_NET', 'wd_watchdog.spice')      # netlist exportado de wd_watchdog.sch (xschem)
STDCELL = os.environ.get('WD_STDCELL', '')                # .include de sg13g2_stdcell.spice si el netlist no expande las celdas
def prep_netlist(out='wd_watchdog_sub.spice'):
    """Convierte el top exportado (**.subckt) en un .subckt incluible."""
    s = open(NET).read().replace('**.subckt wd_watchdog', '.subckt wd_watchdog').replace('**.ends', '.ends', 1)
    if STDCELL: s = f'.include {STDCELL}\n' + s
    open(out, 'w').write(s); return os.path.abspath(out)
def xings(t, v, th=0.0, rise=True):
    a, b = v[:-1], v[1:]
    i = np.where((a <= th) & (b > th))[0] if rise else np.where((a >= th) & (b < th))[0]
    return t[i] + (th - a[i]) / (b[i] - a[i]) * (t[i + 1] - t[i])
