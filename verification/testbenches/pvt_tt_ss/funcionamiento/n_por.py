from nf import *
CELL = 'wd_por'
GR = {'DIV': ['XR1'], 'DET': ['XR4'], 'RC': ['XR3', 'XM3'], 'LOG': ['x1', 'x2']}
GNAME = {'DIV': 'divisor R1–R2', 'DET': 'detector RL + MN', 'RC': 'filtro R3·C1 + MDIS', 'LOG': 'inv + and2'}
TEND = 60e-6
RES_POR = {tuple(c): r for c, r in json.load(open(f'{VAL}/res_por.json'))}


def net(c, hint=None):
    m, t, v = c
    vbk = '' if hint is None else 'VBK BK 0 PWL(' + bk_pwl([hint], pre=15e-9, post=15e-9, dt=20e-12) + ')\nRBK BK 0 1k'
    am = ' '.join(f'i(v.xdut.vam_{g.lower()})' for g in GR)
    sv = f'v(vdd) v(xdut.vd) v(xdut.x) v(xdut.vok) v(xdut.delay) v(por_raw_n) i(vdd) {am}'
    return header(m, t, v, 'wd_por: nodos internos, corrientes por rama') + amm(cellnet(CELL), CELL, GR) + f"""
XDUT POR_RAW_N VDD VSS wd_por
CL POR_RAW_N 0 10f
VDD VDD 0 PWL(0 0 10u {v} 40u {v} 50u 0 {TEND*1e6:.0f}u 0)
VSS VSS 0 0
{vbk}
""" + ctl([f'save {sv}', f'tran 5n {TEND*1e6:.0f}u 0 10n', f'wrdata @T@_tr.txt {sv}',
           'dc VDD 0 1.4 2m', f'wrdata @T@_dc.txt {sv}'])


def job(c):
    m, t, v = c; tg = f'por_{m}_{t}_{v}'
    run2(net(c).replace('@T@', tg), tg); d = ld(f'{tg}_tr')
    trel = first(cross(d['time'], d['vpor_raw_n'], 0.5 * v, True, 0.5e-6))
    tg2 = tg + '_bk'; run2(net(c, trel).replace('@T@', tg2), tg2)
    d = ld(f'{tg2}_tr'); dc = ld(f'{tg2}_dc')
    tt = d['time']; y = d['vpor_raw_n']; idd = -d['ivdd']
    rat = y / np.maximum(d['vvdd'], 0.05)   # POR_RAW_N/VDD: la salida sigue a VDD, que todavía sube
    t50 = first(cross(tt, rat, 0.5, True, 3e-6, 40e-6)); t10 = cross(tt, rat, 0.1, True, 3e-6, t50)[-1]; t90 = first(cross(tt, rat, 0.9, True, t50))
    tfall = first(cross(tt, y, 0.5 * v, False, 40e-6))
    vfall = float(np.interp(tfall, tt, d['vvdd']))
    x = dc[dc.dtype.names[0]]
    vok_dc = first(cross(x, dc['vxdutvok'] - 0.5 * x, 0, True, 0.2))
    br = {g: avg(tt, d[[n for n in d.dtype.names if n.endswith('vam_' + g.lower())][0]], 30e-6, 40e-6) for g in GR}
    i_dc = {vv: float(np.interp(vv, x, -dc['ivdd'])) for vv in VDDS}
    rp = RES_POR[c]
    r = dict(t_rel_us=t50 * 1e6, vdd_at_rel=float(np.interp(t50, tt, d['vvdd'])), tr_ps=(t90 - t10) * 1e12,
             vdd_assert=vfall, vok_dc=vok_dc, idd_ua=avg(tt, idd, 30e-6, 40e-6) * 1e6, ipk_ua=float(idd[tt < 40e-6].max() * 1e6),
             **{f'i_{g.lower()}_ua': x_ * 1e6 for g, x_ in br.items()},
             v_rel_slow=rp['va'], v_assert_slow=rp['vc'], d_fast_us=rp['dd'], d_cut_us=rp['de'],
             ok=bool(np.isfinite(t50)))
    return c, r, (d, dc)


def plots(res):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        fig, ax = plt.subplots(5, 1, figsize=(9.8, 9.6), sharex=True)
        for (mm, t, v), r, (d, dc) in rr:
            s = P.style(t, v); tt = d['time'] * 1e6
            ax[0].plot(tt, d['vvdd'], **s); ax[0].plot(tt, d['vxdutvd'], **dict(s, linewidth=1.0, alpha=0.55))
            ax[1].plot(tt, d['vxdutx'], **s); ax[2].plot(tt, d['vxdutvok'], **s); ax[3].plot(tt, d['vxdutdelay'], **s); ax[4].plot(tt, d['vpor_raw_n'], **s)
        ax[0].set(title='VDD (trazo pleno) y VD = k·VDD del divisor (tenue)', ylabel='V')
        ax[1].set(title='X: drenaje de MN (carga RL) — baja cuando VD supera el V_GS de MN', ylabel='V')
        ax[2].set(title='VOK = NOT X (nivel de VDD suficiente)', ylabel='V')
        ax[3].set(title='DELAY: filtro R3·C1 (sigue a VDD con τ ≈ 1,2 µs; MDIS lo descarga al caer VDD)', ylabel='V')
        ax[4].set(title='POR_RAW_N = VOK · DELAY', ylabel='V', xlabel='t (µs)')
        P.legend(ax[0], loc='upper right', ncol=2)
        suptitle(fig, f'wd_por · mos_{m} · nodos internos: subida de VDD en 10 µs, meseta y bajada en 10 µs', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'Liberación a t = {min(r["t_rel_us"] for r in rr0):.2f}–{max(r["t_rel_us"] for r in rr0):.2f} µs (VDD = {min(r["vdd_at_rel"] for r in rr0):.2f}–{max(r["vdd_at_rel"] for r in rr0):.2f} V) · '
                   f'aserción en la bajada con VDD = {min(r["vdd_assert"] for r in rr0):.2f}–{max(r["vdd_assert"] for r in rr0):.2f} V · t_r de POR_RAW_N/VDD {min(r["tr_ps"] for r in rr0):.0f}–{max(r["tr_ps"] for r in rr0):.0f} ps (10 fF)')
        P.save(fig, f'{G}/wd_por/{m}/por_{m}_nodos_internos.png')
        # corrientes
        fig = plt.figure(figsize=(11.5, 7.6)); gs = fig.add_gridspec(2, 2, height_ratios=[1, 1.1], hspace=0.45, wspace=0.22)
        a0 = fig.add_subplot(gs[0, 0]); a1 = fig.add_subplot(gs[0, 1]); a2 = fig.add_subplot(gs[1, :])
        for (mm, t, v), r, (d, dc) in rr:
            if v == 1.2:
                x = dc[dc.dtype.names[0]]; a0.plot(x, -dc['ivdd'] * 1e6, color=P.TCOL[t], lw=1.6, label=f'{t} °C')
                for vv in VDDS: a0.plot(vv, np.interp(vv, x, -dc['ivdd']) * 1e6, 'o', color=P.TCOL[t], ms=4.5)
            a1.plot(d['time'] * 1e6, -d['ivdd'] * 1e6, **dict(P.style(t, v), linewidth=1.2))
        a0.axvspan(1.08, 1.32, color='#1baf7a', alpha=0.07, lw=0)
        a0.set(title='I_DD estático vs VDD (DC)', xlabel='VDD (V)', ylabel='µA', xlim=(0, 1.4)); a0.legend(loc='upper left', fontsize=8.5)
        a1.set(title='I_DD en el tiempo (rampas de 10 µs)', xlabel='t (µs)', ylabel='µA'); P.legend(a1, loc='upper right', ncol=2)
        bot = np.zeros(len(rr))
        for j, g in enumerate(GR):
            vals = np.array([r[f'i_{g.lower()}_ua'] for _, r, _ in rr])
            a2.bar(range(len(rr)), vals, bottom=bot, color=CAT[j], width=0.62, edgecolor=P.SURF, linewidth=1.2, label=GNAME[g]); bot += vals
        for i, (_, r, _) in enumerate(rr): a2.text(i, bot[i] + 0.03, f'{r["idd_ua"]:.2f}', ha='center', fontsize=8.5, color=P.INK)
        a2.set_xticks(range(len(rr)), [f'{t} °C\n{v:.2f} V' for (mm, t, v), _, _ in rr], fontsize=8.5)
        a2.set(title='Consumo estático por rama (POR liberado)', ylabel='µA', ylim=(0, bot.max() * 1.18)); a2.grid(axis='x', visible=False)
        a2.legend(loc='upper left', ncol=4, fontsize=8.5)
        suptitle(fig, f'wd_por · mos_{m} · consumo', y=0.98)
        P.save(fig, f'{G}/wd_por/{m}/por_{m}_corrientes.png')


if __name__ == '__main__':
    res = pmap(job, grid()); plots(res)
    save_met(CELL, [(c, r) for c, r, _ in res])
    for c, r, _ in res: print(c, {k: (round(x, 3) if isinstance(x, float) else x) for k, x in r.items()})
