from nf import *
CELL = 'schmitt'
CL = '10f'


def job(c):
    m, t, v = c; tg = f'schmitt_{m}_{t}_{v}'
    n = header(m, t, v, 'schmitt: transitorio, conmutación y corriente DC') + cellnet('schmitt') + f"""
* XA: entrada triangular lenta (0 -> VDD en 10 us -> 0)   XB: escalón rápido (50 ps)
XA INA OUTA VDDA VSS schmitt
XB INB OUTB VDDB VSS schmitt
CLA OUTA 0 {CL}
CLB OUTB 0 {CL}
VDDA VDDA 0 {v}
VDDB VDDB 0 {v}
VSS VSS 0 0
VINA INA 0 PWL(0 0 10u {v} 20u 0)
VINB INB 0 PWL(0 0 1n 0 1.05n {v} 6n {v} 6.05n 0)
""" + ctl(['tran 2n 20u 0 5n',
           f'wrdata {tg}_tri.txt v(ina) v(outa) i(vdda)',
           'tran 0.2p 12n 0 2p',
           f'wrdata {tg}_stp.txt v(inb) v(outb) i(vddb)',
           f'dc VINA 0 {v} 0.5m',
           f'wrdata {tg}_dcu.txt v(outa) i(vdda)',
           f'dc VINA {v} 0 -0.5m',
           f'wrdata {tg}_dcd.txt v(outa) i(vdda)'])
    log = run2(n, tg)
    tri, st, du, dd = (ld(f'{tg}_{k}') for k in ('tri', 'stp', 'dcu', 'dcd'))
    tt = st['time']; vi = st['vinb']; vo = st['voutb']; i = -st['ivddb']
    tin_r = 1.025e-9; tin_f = 6.025e-9
    a, b, cc = edge_times(tt, vo, v, False, 1e-9, 6e-9); tphl, tf = b - tin_r, cc - a
    a2, b2, c2 = edge_times(tt, vo, v, True, 6e-9); tplh, tr_ = b2 - tin_f, c2 - a2
    ileak_lo = float(-du['ivdda'][0]); ileak_hi = float(-du['ivdda'][-1])
    q = integ(tt, i, 0.9e-9, 12e-9) - ileak_lo * (12e-9 - 0.9e-9)
    vin_u = du[du.dtype.names[0]]
    ipk_dc = max(float((-du['ivdda']).max()), float((-dd['ivdda']).max()))
    r = dict(tphl_ps=tphl * 1e12, tplh_ps=tplh * 1e12, tf_ps=tf * 1e12, tr_ps=tr_ * 1e12,
             ipk_tr_ua=float(i.max() * 1e6), ipk_dc_ua=ipk_dc * 1e6, ileak_lo_pa=ileak_lo * 1e12, ileak_hi_pa=ileak_hi * 1e12,
             e_cycle_fj=q * v * 1e15, ok=bool(np.isfinite(tphl) and np.isfinite(tplh) and tphl < 200e-12 and tplh < 200e-12))
    return c, r, (tri, st, du, dd)


def plots(res):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        # 1) transitorio con entrada triangular
        fig, ax = plt.subplots(3, 1, figsize=(9.5, 6.6), sharex=True, gridspec_kw=dict(height_ratios=[1, 1, 1.1]))
        for (mm, t, v), r, (tri, st, du, dd) in rr:
            s = P.style(t, v); tt = tri['time'] * 1e6
            ax[0].plot(tt, tri['vina'], **s); ax[1].plot(tt, tri['vouta'], **s); ax[2].plot(tt, -tri['ivdda'] * 1e6, **s)
        ax[0].set(title='IN: rampa 0 → VDD → 0 (10 µs por tramo)', ylabel='V')
        ax[1].set(title='OUT (carga 10 fF)', ylabel='V')
        ax[2].set(title='I_DD: corriente de cortocircuito al cruzar los umbrales', ylabel='µA', xlabel='t (µs)')
        P.legend(ax[0], loc='upper right', ncol=2)
        suptitle(fig, f'schmitt · mos_{m} · funcionamiento en el tiempo', y=1.0)
        fig.tight_layout()
        P.subtitle(fig, 'Pico de I_DD en DC (µA): ' + ', '.join(f'{r["ipk_dc_ua"]:.1f}' for _, r, _ in rr) +
                   '  ·  fuga con IN = 0 (pA): ' + ', '.join(f'{r["ileak_lo_pa"]:.0f}' for _, r, _ in rr))
        P.save(fig, f'{G}/schmitt/{m}/schmitt_{m}_transitorio_y_corriente.png')
        # 2) conmutación rápida
        fig, ax = plt.subplots(2, 2, figsize=(10.5, 5.6), sharex='col', gridspec_kw=dict(height_ratios=[1.2, 1]))
        for (mm, t, v), r, (tri, st, du, dd) in rr:
            s = P.style(t, v); tt = st['time']
            for j, (a, b, t0) in enumerate(((0.9e-9, 1.5e-9, 1.025e-9), (5.9e-9, 6.5e-9, 6.025e-9))):
                k = (tt > a) & (tt < b)
                ax[0, j].plot((tt[k] - t0) * 1e12, st['vinb'][k] / v, color=P.GRID, lw=1.2, zorder=0)
                ax[0, j].plot((tt[k] - t0) * 1e12, st['voutb'][k] / v, **s)
                ax[1, j].plot((tt[k] - t0) * 1e12, -st['ivddb'][k] * 1e6, **s)
        ax[0, 0].set(title='IN ↑ (50 ps) → OUT ↓', ylabel='V / VDD'); ax[0, 1].set(title='IN ↓ (50 ps) → OUT ↑')
        ax[1, 0].set(ylabel='I_DD (µA)', xlabel='t − 50 % de IN (ps)'); ax[1, 1].set(xlabel='t − 50 % de IN (ps)')
        ax[0, 0].text(-100, 0.85, 'IN', color=P.INK2, fontsize=8.5)
        P.legend(ax[0, 1], loc='center right', ncol=1)
        suptitle(fig, f'schmitt · mos_{m} · retardos y tiempos de transición (carga 10 fF)', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f't_pHL {min(r["tphl_ps"] for r in rr0):.0f}–{max(r["tphl_ps"] for r in rr0):.0f} ps · t_pLH {min(r["tplh_ps"] for r in rr0):.0f}–{max(r["tplh_ps"] for r in rr0):.0f} ps · '
                   f't_f {min(r["tf_ps"] for r in rr0):.0f}–{max(r["tf_ps"] for r in rr0):.0f} ps · t_r {min(r["tr_ps"] for r in rr0):.0f}–{max(r["tr_ps"] for r in rr0):.0f} ps (10–90 %) · '
                   f'energía por ciclo {min(r["e_cycle_fj"] for r in rr0):.1f}–{max(r["e_cycle_fj"] for r in rr0):.1f} fJ')
        P.save(fig, f'{G}/schmitt/{m}/schmitt_{m}_conmutacion.png')
        # 3) corriente DC vs VIN
        fig, ax = plt.subplots(figsize=(6.6, 4.0))
        for (mm, t, v), r, (tri, st, du, dd) in rr:
            s = P.style(t, v)
            ax.plot(du[du.dtype.names[0]], -du['ivdda'] * 1e6, **s); ax.plot(dd[dd.dtype.names[0]], -dd['ivdda'] * 1e6, **s)
        ax.set(xlabel='V(IN) (V)', ylabel='I_DD (µA)')
        ax.set_title(f'schmitt · mos_{m} · corriente de alimentación vs entrada (DC, ambos sentidos)', loc='left', fontsize=10)
        P.legend(ax, loc='upper right', ncol=2)
        P.subtitle(fig, 'El pico aparece justo antes de cada umbral; la realimentación (XM8/XM9) lo corta al conmutar.')
        P.save(fig, f'{G}/schmitt/{m}/schmitt_{m}_corriente_DC.png')


if __name__ == '__main__':
    res = pmap(job, grid()); plots(res)
    save_met(CELL, [(c, r) for c, r, _ in res])
    for c, r, _ in res: print(c, {k: (round(x, 2) if isinstance(x, float) else x) for k, x in r.items()})
