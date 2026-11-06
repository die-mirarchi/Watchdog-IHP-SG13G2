"""Figura de presupuesto de consumo para el PDF (tt típico y peor caso por bloque)."""
from nf import *
M = {k: {tuple(c): r for c, r in json.load(open(f'{MET}/{k}.json'))} for k in ['wd_oscillater', 'wd_por', 'wd_reset_sync', 'EN_INPUT', 'WDI_INPUT']}
o, p = M['wd_oscillater'], M['wd_por']
CATS = [('osc · bias', lambda c: o[c]['i_bias_ua']),
        ('osc · comparadores', lambda c: o[c]['i_cinf_ua'] + o[c]['i_csup_ua']),
        ('osc · divisor R1–R3', lambda c: o[c]['i_div_ua']),
        ('osc · buf_1 + latch + buf_4', lambda c: o[c]['i_drv_ua'] + o[c]['i_log_ua']),
        ('POR · divisor', lambda c: p[c]['i_div_ua']),
        ('POR · detector + lógica', lambda c: p[c]['i_det_ua'] + p[c]['i_log_ua']),
        ('sync + EN + WDI (10 kHz)', lambda c: sum(M[k][c]['iavg_na'] for k in ('wd_reset_sync', 'EN_INPUT', 'WDI_INPUT')) * 1e-3)]
conds = [(m, t, v) for m in CORNERS for t in TEMPS for v in VDDS]
tot = lambda c: sum(f(c) for _, f in CATS)
worst = max(conds, key=tot); best = min(conds, key=tot)
rows = [('Mínimo: ' + f'{best[0]} · {best[1]} °C · {best[2]:.2f} V', best), ('Típico: tt · 27 °C · 1.20 V', ('tt', 27, 1.2)),
        ('Máximo: ' + f'{worst[0]} · {worst[1]} °C · {worst[2]:.2f} V', worst)]
fig, ax = plt.subplots(figsize=(10, 3.4))
for i, (lab, c) in enumerate(rows):
    x0 = 0
    for j, (n, f) in enumerate(CATS):
        w = f(c); ax.barh(i, w, left=x0, color=CAT[j], height=0.55, edgecolor=P.SURF, linewidth=1.2, label=n if i == 0 else None); x0 += w
    ax.text(x0 + 0.15, i, f'{x0:.2f} µA', va='center', fontsize=9, color=P.INK)
ax.set_yticks(range(len(rows)), [r[0] for r in rows], fontsize=9); ax.invert_yaxis()
ax.set(xlabel='I_DD media (µA)', xlim=(0, max(tot(c) for c in conds) * 1.15)); ax.grid(axis='y', visible=False)
ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.28), ncol=4, fontsize=8.5)
ax.set_title('Presupuesto de consumo de los bloques verificados (las 18 condiciones: mínimo, típico y máximo)', loc='left', fontsize=10)

fig.savefig(f'{MET}/consumo.png', dpi=200, bbox_inches='tight'); plt.close(fig)
for lab, c in rows: print(lab, round(tot(c), 3))
