from nf import *
import gen_integracion as IG
R0 = {tuple(c): r for c, r in json.load(open(f'{VAL}/res_integ.json'))}


def job(c):
    m, t, v = c
    order = [R0[c]['tmax']] + [x for x in ['100n', '70n', '130n', '50n', '150n'] if x != R0[c]['tmax']]
    for tm in order:
        tg = f'integ_{m}_{t}_{v}_{tm}'
        blk = IG.block(v, t, tm, plots=False).replace('@OUT@', f'{tg}.txt').replace('  set wr_singlescale', '  set wr_singlescale\n  set wr_vecnames')
        blk = blk.replace('v(x2.p1) v(por_b)', 'v(x2.p1) v(por_b) i(VVDD) i(VAMP) i(VAMO)')
        top = f"""* integracion wd_oscillater + wd_por + wd_reset_sync(digital) con amperimetros por bloque -- mos_{m} {t} C {v} V
x1 POR_RAW_N VDD_P VSS wd_por
VAMP VDD VDD_P 0
x2 POR_RAW_N CLK POR_B VDD VSS wd_reset_sync
x3 CLK VDD_O VSS wd_oscillater
VAMO VDD VDD_O 0
C1 POR_B VSS 50f
.lib {MOD}/cornerMOSlv.lib mos_{m}
.lib {MOD}/cornerRES.lib res_typ
.lib {MOD}/cornerCAP.lib cap_typ
.include {SC}
"""
        n = top + blk + cellnet('wd_por') + cellnet('wd_oscillater') + '.end\n'
        lf = f'{OUT}/{tg}.log'
        if os.path.exists(lf) and os.path.exists(f'{OUT}/{tg}.txt') and 'VEREDICTO' in open(lf).read():
            log = open(lf).read()          # corrida ya hecha (misma netlist)
        else:
            log = run2(n, tg)
        ok = 'VEREDICTO: PASS' in log and 'aborted' not in log
        if ok: break
    d = ld(tg); d.dtype.names = [x.lower() for x in d.dtype.names]; tt = d['time']
    r = {}
    for k in ['vRA', 'vBA', 'latA', 'vRC', 'vBC', 'latC', 'tD', 'idd_ua']:
        mm = re.search(r'^%s\s+=\s+([-\d.eE+]+)' % k, log, re.M | re.I)
        if mm: r[k] = float(mm.group(1))
    tB = first(cross(tt, d['vpor_b'], v / 2, True, 0, 400e-6))
    r.update(ok=ok, tmax=tm, t_porb_A_us=tB * 1e6,
             i_tot_ua=avg(tt, -d['ivvdd'], 600e-6, 800e-6) * 1e6, i_por_ua=avg(tt, d['ivamp'], 600e-6, 800e-6) * 1e6,
             i_osc_ua=avg(tt, d['ivamo'], 600e-6, 800e-6) * 1e6, ipk_ua=float((-d['ivvdd']).max() * 1e6))
    return c, r, d


def plots(res):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        fig = plt.figure(figsize=(11.5, 9.4)); gs = fig.add_gridspec(4, 1, height_ratios=[0.8, 0.8, 1.2, 1.15], hspace=0.62)
        ax = [fig.add_subplot(gs[i]) for i in range(4)]
        for i in (1, 2): ax[i].sharex(ax[0])
        for (mm, t, v), r, d in rr:
            s = P.style(t, v); tt = d['time'] * 1e6
            ax[0].plot(tt, d['vvdd'], **s); ax[1].plot(tt, d['vpor_b'], **s)
            ax[2].plot(tt, np.maximum(-d['ivvdd'] * 1e6, 0.1), **dict(s, linewidth=1.0))
        ax[0].set(title='VDD: A) rampa de 10 µs · B) caída a 0,45 V durante 90 µs · C) apagado y rampa de 1 ms', ylabel='V')
        ax[1].set(title='POR_B (salida del sincronizador)', ylabel='V')
        ax[2].set(title='I_DD total (oscilador + POR; el sincronizador va en XSPICE y no consume)', ylabel='µA (log)', yscale='log', xlabel='t (µs)', ylim=(0.1, None))
        P.legend(ax[2], loc='upper left', ncol=2, bbox_to_anchor=(0.385, 1.0))
        bot = np.zeros(len(rr))
        for j, (k, lab) in enumerate((('i_osc_ua', 'wd_oscillater'), ('i_por_ua', 'wd_por'))):
            vals = np.array([r[k] for _, r, _ in rr]); ax[3].bar(range(len(rr)), vals, bottom=bot, color=CAT[j], width=0.62, edgecolor=P.SURF, linewidth=1.2, label=lab); bot += vals
        for i, (_, r, _) in enumerate(rr): ax[3].text(i, bot[i] + 0.2, f'{r["i_tot_ua"]:.1f}', ha='center', fontsize=8.5, color=P.INK)
        ax[3].set_xticks(range(len(rr)), [f'{t} °C\n{v:.2f} V' for (mm, t, v), _, _ in rr], fontsize=8.5)
        ax[3].set(title='Consumo medio en régimen (600–800 µs)', ylabel='µA', ylim=(0, bot.max() * 1.2)); ax[3].grid(axis='x', visible=False)
        ax[3].legend(loc='upper left', ncol=2, fontsize=8.5)
        suptitle(fig, f'Integración osc + POR + sincronizador · mos_{m} · tensiones y consumo', y=0.985)
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'POR_B se libera {min(r["t_porb_A_us"] for r in rr0):.0f}–{max(r["t_porb_A_us"] for r in rr0):.0f} µs después de iniciar la rampa A. '
                   f'I_DD total en régimen {min(r["i_tot_ua"] for r in rr0):.1f}–{max(r["i_tot_ua"] for r in rr0):.1f} µA; pico {max(r["ipk_ua"] for r in rr0):.0f} µA.')
        P.save(fig, f'{G}/integracion/{m}/integracion_{m}_consumo.png')


if __name__ == '__main__':
    res = pmap(job, grid()); plots(res)
    save_met('integracion', [(c, r) for c, r, _ in res])
    for c, r, _ in res: print(c, {k: (round(x, 2) if isinstance(x, float) else x) for k, x in r.items()})
