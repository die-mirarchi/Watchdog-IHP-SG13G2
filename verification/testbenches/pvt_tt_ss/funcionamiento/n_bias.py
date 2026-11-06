from nf import *
CELL = 'bias'
IDS = {'iref': '@n.xb.xm1.nsg13_lv_nmos[ids]', 'iout': '@n.xb.xm3.nsg13_lv_nmos[ids]'}


def job(c):
    m, t, v = c; tg = f'bias_{m}_{t}_{v}'
    n = header(m, t, v, 'bias: corrientes (arranque, VDD, T)') + cellnet('bias') + f"""
XB VBP VBN VDD VSS bias
VDD VDD 0 PWL(0 0 0.1u {v})
VSS VSS 0 0
""" + ctl([f'save v(vdd) v(vbn) v(vbp) i(vdd) {IDS["iref"]} {IDS["iout"]}',
           'tran 1n 6u 0 5n',
           f'wrdata {tg}_tr.txt v(vdd) v(vbn) v(vbp) i(vdd) {IDS["iref"]} {IDS["iout"]}',
           'alter VDD dc=0',
           f'dc VDD 0 1.4 2m',
           f'wrdata {tg}_vdd.txt v(vbn) v(vbp) i(vdd) {IDS["iref"]} {IDS["iout"]}',
           f'alter VDD dc={v}',
           'dc TEMP -40 85 1',
           f'wrdata {tg}_T.txt v(vbn) v(vbp) i(vdd) {IDS["iref"]} {IDS["iout"]}'])
    log = run2(n, tg)
    tr = ld(f'{tg}_tr'); dv = ld(f'{tg}_vdd'); dT = ld(f'{tg}_T')
    names = tr.dtype.names
    kr = [k for k in names if 'xm1' in k][0]; ko = [k for k in names if 'xm3' in k][0]
    tt = tr['time']; iref = tr[kr]; iout = tr[ko]; idd = -tr['ivdd']
    fin = iout[-1]
    bad = np.where(np.abs(iout - fin) > 0.01 * fin)[0]
    tset = tt[bad[-1] + 1] if len(bad) else 0.0
    # DC vs VDD
    x = dv[dv.dtype.names[0]]; io = dv[[k for k in dv.dtype.names if 'xm3' in k][0]]
    i108, i12, i132 = (float(np.interp(a, x, io)) for a in (1.08, 1.2, 1.32))
    line = (i132 - i108) / i12 / 0.24 * 100  # %/V
    # DC vs T
    xT = dT[dT.dtype.names[0]]; ioT = dT[[k for k in dT.dtype.names if 'xm3' in k][0]]
    tc = (np.interp(85, xT, ioT) - np.interp(-40, xT, ioT)) / np.interp(27, xT, ioT) / 125 * 1e6  # ppm/°C
    # VDD mínima: corriente de salida >= 90 % del valor a 1,2 V
    ir = dv[[k for k in dv.dtype.names if 'xm1' in k][0]]
    von = float(x[np.where(io >= 0.1e-6)[0][0]])  # VDD de encendido: I_OUT >= 0,1 µA
    r = dict(iref_ua=iref[-1] * 1e6, iout_ua=fin * 1e6, idd_ua=idd[-1] * 1e6, vbn=tr['vvbn'][-1], vsg=v - tr['vvbp'][-1],
             tset_us=tset * 1e6, line_pct_v=line, tc_ppm=tc, vdd_on=von, mirror_err_pct=(fin / iref[-1] - 1) * 100, peak_ua=idd.max() * 1e6,
             ok=bool(abs(fin) > 0.5e-6 and tset < 5e-6))
    return c, r, (tr, dv, dT)


def plots(res):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        # 1) corrientes en el tiempo
        fig, ax = plt.subplots(1, 3, figsize=(12, 3.7), sharey=False)
        for (mm, t, v), r, (tr, dv, dT) in rr:
            s = P.style(t, v); tt = tr['time'] * 1e6; nm = tr.dtype.names
            ax[0].plot(tt, tr[[k for k in nm if 'xm1' in k][0]] * 1e6, **s)
            ax[1].plot(tt, tr[[k for k in nm if 'xm3' in k][0]] * 1e6, **s)
            ax[2].plot(tt, -tr['ivdd'] * 1e6, **s)
        ax[0].set(title='I_REF (XM1, diodo NMOS)', xlabel='t (µs)', ylabel='µA')
        ax[1].set(title='I_OUT (XM3 → XM2, espejo)', xlabel='t (µs)')
        ax[2].set(title='I_DD total', xlabel='t (µs)')
        P.legend(ax[2], loc='lower right', ncol=2)
        suptitle(fig, f'bias · mos_{m} · corrientes en el arranque (escalón de VDD de 100 ns)', y=1.03)
        fig.tight_layout()
        P.subtitle(fig, 'Establecimiento de I_OUT al 1 % desde t = 0 (µs): ' + ', '.join(f'{r["tset_us"]:.2f}' for _, r, _ in rr) +
                   '  ·  I_OUT final (µA): ' + ', '.join(f'{r["iout_ua"]:.2f}' for _, r, _ in rr))
        P.save(fig, f'{G}/bias/{m}/bias_{m}_corrientes_arranque.png')
        # 2) corriente vs VDD y vs T
        fig, ax = plt.subplots(1, 2, figsize=(11, 3.9))
        for (mm, t, v), r, (tr, dv, dT) in rr:
            if v != 1.2: continue  # el barrido de VDD no depende de la VDD nominal
            x = dv[dv.dtype.names[0]]; nm = dv.dtype.names
            ax[0].plot(x, dv[[k for k in nm if 'xm3' in k][0]] * 1e6, color=P.TCOL[t], lw=1.6)
            ax[0].plot(x, -dv['ivdd'] * 1e6, color=P.TCOL[t], lw=1.0, alpha=0.55)
            for vv in VDDS:
                ax[0].plot(vv, np.interp(vv, x, dv[[k for k in nm if 'xm3' in k][0]]) * 1e6, 'o', color=P.TCOL[t], ms=4.5)
        ax[0].axvspan(1.08, 1.32, color='#1baf7a', alpha=0.07, lw=0)
        ax[0].text(1.1, ax[0].get_ylim()[1] * 0.04 if False else 0.15, 'rango\n1.08–1.32 V', fontsize=7.5, color=P.INK2)
        ax[0].set(title='Corriente vs VDD (DC)', xlabel='VDD (V)', ylabel='µA', xlim=(0, 1.4))
        ax[0].legend(handles=[plt.Line2D([], [], color=P.TCOL[t], lw=2, label=f'{t} °C') for t in TEMPS] +
                     [plt.Line2D([], [], color=P.INK2, lw=1.6, label='I_OUT (espejo)'), plt.Line2D([], [], color=P.INK2, lw=1, alpha=0.55, label='I_DD total')],
                     loc='upper left', fontsize=8.5)
        for v in VDDS:
            (mm, t, vv), r, (tr, dv, dT) = [x for x in rr if x[0][2] == v][0]
            xT = dT[dT.dtype.names[0]]; nm = dT.dtype.names
            ax[1].plot(xT, dT[[k for k in nm if 'xm3' in k][0]] * 1e6, color=P.INK2, linestyle=P.VLS[v], lw=1.6, label=f'{v:.2f} V')
            for t in TEMPS:
                ax[1].plot(t, np.interp(t, xT, dT[[k for k in nm if 'xm3' in k][0]]) * 1e6, 'o', color=P.TCOL[t], ms=5, zorder=3)
        ax[1].set(title='I_OUT vs temperatura (DC)', xlabel='T (°C)', ylabel='µA', xticks=[-40, -20, 0, 27, 50, 85])
        ax[1].legend(loc='upper left', fontsize=8.5)
        suptitle(fig, f'bias · mos_{m} · sensibilidad de la corriente a VDD y a T', y=1.03)
        fig.tight_layout()
        r0 = [r for (mm, t, v), r, _ in rr]
        P.subtitle(fig, f'Regulación de línea {min(r["line_pct_v"] for r in r0):.0f}–{max(r["line_pct_v"] for r in r0):.0f} %/V  ·  coef. térmico '
                   f'{min(r["tc_ppm"] for r in r0):.0f}–{max(r["tc_ppm"] for r in r0):.0f} ppm/°C (fuente referida a resistencia: I ≈ (VDD − V_GS)/R1).\n'
                   f'Error de copia del espejo I_OUT/I_REF − 1: {min(r["mirror_err_pct"] for r in r0):.1f}–{max(r["mirror_err_pct"] for r in r0):.1f} % (V_DS distinto en XM1 y XM3). Puntos: condiciones del barrido.')
        P.save(fig, f'{G}/bias/{m}/bias_{m}_corriente_vs_VDD_y_T.png')


if __name__ == '__main__':
    res = pmap(job, grid()); plots(res)
    save_met(CELL, [(c, r) for c, r, _ in res])
    for c, r, _ in res: print(c, {k: (round(x, 3) if isinstance(x, float) else x) for k, x in r.items()})
