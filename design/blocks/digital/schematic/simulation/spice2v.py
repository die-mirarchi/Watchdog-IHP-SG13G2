#!/usr/bin/env python3
# spice2v.py -- convierte un netlist SPICE exportado por xschem (celdas sg13g2 y
# subcircuitos propios) en Verilog estructural para simular la logica en Icarus
# con los modelos de IHP. Cada instancia del esquematico pasa 1:1.
# Uso: python3 spice2v.py <netlist.spice> <sg13g2_stdcell.spice> <salida.v>
import re, sys

net, cells, out = sys.argv[1:4]

# orden de pines de las celdas de la libreria (de su .subckt)
cpins = {}
for l in open(cells):
    m = re.match(r'\.subckt\s+(sg13g2_\w+)\s+(.*)', l, re.I)
    if m:
        cpins[m.group(1)] = m.group(2).split()

txt = open(net).read().replace('\n+', ' ')
# subcircuitos del usuario: el top de xschem viene como "**.subckt", el resto como ".subckt"
subs = []
cur = None
for l in txt.splitlines():
    s = l.strip()
    m = re.match(r'\*{0,2}\.subckt\s+(\w+)\s*(.*)', s, re.I)
    if m and not m.group(1).startswith('sg13g2_'):
        cur = dict(name=m.group(1), pins=m.group(2).split(), inst=[], io={})
        subs.append(cur); continue
    if cur is None:
        continue
    if re.match(r'\*{0,2}\.ends', s, re.I):
        cur = None; continue
    m = re.match(r'\*\.(ipin|opin|iopin)\s+(\w+)', s)
    if m:
        cur['io'][m.group(2)] = m.group(1); continue
    if s and s[0] in 'xX':
        t = s.split()
        cur['inst'].append((t[0], t[1:-1], t[-1]))

upins = {s['name']: s['pins'] for s in subs}
def vname(n):
    n = n.replace('#', '_')
    return n if re.match(r'^[A-Za-z_]\w*$', n) else '\\' + n + ' '

o = ['// Generado por spice2v.py a partir de ' + net.split('/')[-1] + ' (no editar a mano)', '`timescale 1ns/1ps']
for s in subs:
    ports = [p for p in s['pins'] if p not in ('VDD', 'VSS')]
    o.append(f"module {s['name']} ({', '.join(vname(p) for p in ports)});")
    for p in ports:
        d = {'ipin': 'input', 'opin': 'output', 'iopin': 'inout'}.get(s['io'].get(p), 'inout')
        o.append(f'  {d} {vname(p)};')
    nets = set()
    for _, ns, _ in s['inst']:
        nets |= set(ns)
    nets -= set(s['pins']) | {'VDD', 'VSS'}
    for n in sorted(nets):
        o.append(f'  wire {vname(n)};')
    for name, ns, cell in s['inst']:
        if cell in cpins:
            pins = cpins[cell]
            conn = [f'.{p}({vname(n)})' for p, n in zip(pins, ns) if p not in ('VDD', 'VSS')]
        elif cell in upins:
            pins = upins[cell]
            conn = [f'.{p}({vname(n)})' for p, n in zip(pins, ns) if p not in ('VDD', 'VSS')]
        else:
            sys.exit(f'celda desconocida: {cell}')
        if len(ns) != len(pins):
            sys.exit(f'{name}: {len(ns)} nodos para {len(pins)} pines de {cell}')
        o.append(f"  {cell} {name} ({', '.join(conn)});")
    o.append('endmodule\n')
open(out, 'w').write('\n'.join(o))
print(f'{out}: ' + ', '.join(s['name'] for s in subs))
