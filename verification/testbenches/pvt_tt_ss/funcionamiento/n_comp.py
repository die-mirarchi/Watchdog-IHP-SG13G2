from nf import *
OD = 20e-3      # sobreexcitación respecto del punto de disparo
T1, T2, TE = 20e-6, 60e-6, 100e-6
OFF = {k: {tuple(c): r['offset_mv'] * 1e-3 for c, r in v} for k, v in json.load(open(f'{VAL}/res_analog.json')).items() if k.startswith('comp')}


def job(c, cell, hint=None):
    m, t, v = c; tg = f'{cell}_{m}_{t}_{v}'; off = OFF[cell][c]
    if cell == 'comp_sup':
        vref = 2 * v / 3; trip = vref + off          # dispara cuando VP - VN = off
        lo, hi = trip - OD, trip + OD
        inst = 'XC VBN VP VN OUT VDD VSS comp_sup'; fixed = f'VNN VN 0 {vref}'
        sw = f'VPP VP 0 PWL(0 {lo} {T1} {lo} {T1+1e-9} {hi} {T2} {hi} {T2+1e-9} {lo})'; src = 'VPP'
        tail, stage = '@n.xc.xm6.nsg13_lv_nmos[ids]', '@n.xc.xm7.nsg13_lv_nmos[ids]'
    else:
        vref = v / 3; trip = vref - off               # VP - VN = off  ->  VN = VP - off
        lo, hi = trip - OD, trip + OD
        inst = 'XC VBP VP VN OUT VDD VSS comp_inf'; fixed = f'VPP VP 0 {vref}'
        sw = f'VNN VN 0 PWL(0 {lo} {T1} {lo} {T1+1e-9} {hi} {T2} {hi} {T2+1e-9} {lo})'; src = 'VNN'
        tail, stage = '@n.xc.xm1.nsg13_lv_pmos[ids]', '@n.xc.xm2.nsg13_lv_pmos[ids]'
    vbk = ''
    if hint:   # 2.a pasada: puntos cada 20 ps alrededor de los flancos de OUT (sin efecto eléctrico)
        vbk = 'VBK BK 0 PWL(' + bk_pwl([T1 + hint[0], T2 + hint[1]], pre=12e-9, post=12e-9, dt=20e-12) + ')\nRBK BK 0 1k'
    sv = f'v(vp) v(vn) v(xc.out1) v(xc.out2) v(out) i(vdd) {tail} {stage}'
    n = header(m, t, v, f'{cell}: respuesta temporal y corrientes') + cellnet('bias') + cellnet(cell) + f"""
* bias en alimentación separada (VDDB): i(vdd) es solo el comparador
XB VBP VBN VDDB VSS bias
{inst}
COUT OUT 0 10f
{vbk}
VDD VDD 0 {v}
VDDB VDDB 0 {v}
VSS VSS 0 0
{fixed}
{sw}
""" + ctl([f'save {sv}', f'tran 5n {TE*1e6:.0f}u 0 5n', f'wrdata {tg}_tr.txt {sv}',
           f'dc {src} {trip-0.06:.5f} {trip+0.06:.5f} 0.1m', f'wrdata {tg}_dc.txt {sv}'])
    log = run2(n, tg)
    tr = ld(f'{tg}_tr'); dc = ld(f'{tg}_dc')
    tt = tr['time']; vo = tr['vout']; idd = -tr['ivdd']
    nm = tr.dtype.names; kt = [k for k in nm if ('xm6' in k or 'xm1' in k) and 'ids' in k][0]; ks = [k for k in nm if ('xm7' in k or 'xm2' in k) and 'ids' in k][0]
    # primer flanco de OUT tras cada escalón (la polaridad la decide el circuito)
    up_first = vo[(tt > T1 - 1e-6) & (tt < T1)].mean() < v / 2
    a1 = edge_times(tt, vo, v, up_first, T1, T2); a2 = edge_times(tt, vo, v, not up_first, T2, TE)
    (r1, r2) = (a1, a2) if up_first else (a2, a1)  # r1 = flanco de subida de OUT, r2 = bajada
    tlh = r1[1] - (T1 if up_first else T2); thl = r2[1] - (T2 if up_first else T1)
    trr = r1[2] - r1[0]; tff = r2[2] - r2[0]
    i_hi = avg(tt, idd, T2 - 15e-6, T2 - 1e-6) if up_first else avg(tt, idd, TE - 15e-6, TE - 1e-6)
    i_lo = avg(tt, idd, TE - 15e-6, TE - 1e-6) if up_first else avg(tt, idd, T2 - 15e-6, T2 - 1e-6)
    r = dict(tpd_lh_us=tlh * 1e6, tpd_hl_us=thl * 1e6, tr_ps=trr * 1e12, tf_ps=tff * 1e12,
             idd_outhi_ua=i_hi * 1e6, idd_outlo_ua=i_lo * 1e6, itail_ua=abs(float(tr[kt][-1])) * 1e6,
             istage_ua=abs(float(tr[ks][-1])) * 1e6, ipk_ua=float(idd.max()) * 1e6, ipk_dc_ua=float((-dc['ivdd']).max()) * 1e6,
             out_rises_when='VP>VN' if (up_first == (cell == 'comp_sup')) else 'VP<VN', trip=trip,
             d1=a1[1] - T1, d2=a2[1] - T2, ok=bool(np.isfinite(tlh) and np.isfinite(thl)))
    return c, r, (tr, dc)


def plots(res, cell):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        fig, ax = plt.subplots(4, 2, figsize=(11, 8.6), sharex='col', sharey='row', gridspec_kw=dict(height_ratios=[1, 1, 1, 1.1]))
        for (mm, t, v), r, (tr, dc) in rr:
            s = P.style(t, v); tt = tr['time']
            for j, t0 in enumerate((T1, T2)):
                k = (tt > t0 - 60e-9) & (tt < t0 + 450e-9); x = (tt[k] - t0) * 1e9
                ax[0, j].plot(x, tr['vxcout1'][k], **s); ax[1, j].plot(x, tr['vxcout2'][k], **s); ax[2, j].plot(x, tr['vout'][k], **s)
                ax[3, j].plot(x, -tr['ivdd'][k] * 1e6, **s)
        sw = 'VP' if cell == 'comp_sup' else 'VN'
        ax[0, 0].set_title(f'{sw}: umbral − {OD*1e3:.0f} mV → umbral + {OD*1e3:.0f} mV', fontsize=10)
        ax[0, 1].set_title(f'{sw}: umbral + {OD*1e3:.0f} mV → umbral − {OD*1e3:.0f} mV', fontsize=10)
        for j in (0, 1): ax[3, j].set_xlabel('t − escalón de entrada (ns)')
        for i, lab in enumerate(('OUT1 (par diferencial) [V]', 'OUT2 (2.ª etapa) [V]', 'OUT (schmitt, 10 fF) [V]', 'I_DD comparador [µA]')):
            ax[i, 0].set_ylabel(lab, fontsize=8.8)
        for a in ax.flat: a.axvline(0, color=P.INK2, lw=0.7, ls=(0, (2, 2)))
        P.legend(ax[3, 1], loc='upper right', ncol=2)
        ref = 'VN = 2/3·VDD fijo' if cell == 'comp_sup' else 'VP = 1/3·VDD fijo'
        suptitle(fig, f'{cell} · mos_{m} · respuesta a escalones de ±{OD*1e3:.0f} mV alrededor del umbral ({ref}; bias en fuente aparte)', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'Retardo OUT↑ {min(r["tpd_lh_us"] for r in rr0):.2f}–{max(r["tpd_lh_us"] for r in rr0):.2f} µs · OUT↓ {min(r["tpd_hl_us"] for r in rr0):.2f}–{max(r["tpd_hl_us"] for r in rr0):.2f} µs · '
                   f't_r {min(r["tr_ps"] for r in rr0):.0f}–{max(r["tr_ps"] for r in rr0):.0f} ps · t_f {min(r["tf_ps"] for r in rr0):.0f}–{max(r["tf_ps"] for r in rr0):.0f} ps (10–90 %). '
                   f'El escalón se centra en el punto de disparo medido de cada condición.')
        P.save(fig, f'{G}/{cell}/{m}/{cell}_{m}_respuesta_temporal.png')
        # corrientes DC
        fig, ax = plt.subplots(1, 2, figsize=(11, 3.9))
        for (mm, t, v), r, (tr, dc) in rr:
            s = P.style(t, v); nm = dc.dtype.names
            x = (dc['vvp'] - dc['vvn']) * 1e3 - OFF[cell][(mm, t, v)] * 1e3
            ax[0].plot(x, -dc['ivdd'] * 1e6, **s)
            kt = [k for k in nm if ('xm6' in k or 'xm1' in k) and 'ids' in k][0]; ks = [k for k in nm if ('xm7' in k or 'xm2' in k) and 'ids' in k][0]
            ax[1].plot(x, np.abs(dc[kt]) * 1e6, **s); ax[1].plot(x, np.abs(dc[ks]) * 1e6, **dict(s, alpha=0.45))
        ax[0].set(title='I_DD del comparador vs entrada (DC)', xlabel='(VP − VN) − offset (mV)', ylabel='µA')
        tn = 'XM6' if cell == 'comp_sup' else 'XM1'; sn = 'XM7' if cell == 'comp_sup' else 'XM2'
        ax[1].set(title=f'Cola ({tn}, trazo pleno) y fuente de la 2.ª etapa ({sn}, tenue)', xlabel='(VP − VN) − offset (mV)', ylabel='µA')
        P.legend(ax[0], loc='upper right', ncol=2)
        suptitle(fig, f'{cell} · mos_{m} · corrientes de polarización', y=1.03)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'I_cola {min(r["itail_ua"] for r in rr0):.2f}–{max(r["itail_ua"] for r in rr0):.2f} µA · I_DD en reposo {min(min(r["idd_outhi_ua"], r["idd_outlo_ua"]) for r in rr0):.2f}–'
                   f'{max(max(r["idd_outhi_ua"], r["idd_outlo_ua"]) for r in rr0):.2f} µA · pico al cruzar el umbral (DC, schmitt) hasta {max(r["ipk_dc_ua"] for r in rr0):.1f} µA')
        P.save(fig, f'{G}/{cell}/{m}/{cell}_{m}_corrientes.png')


if __name__ == '__main__' and len(sys.argv) > 1 and sys.argv[1] == 'replot':
    for cell in ['comp_sup', 'comp_inf']:
        M = json.load(open(f'{MET}/{cell}.json'))
        plots([(tuple(c), r, (ld(f'{cell}_{c[0]}_{c[1]}_{c[2]}_tr'), ld(f'{cell}_{c[0]}_{c[1]}_{c[2]}_dc'))) for c, r in M], cell)
    sys.exit()
if __name__ == '__main__':
    for cell in ['comp_sup', 'comp_inf']:
        r1 = pmap(lambda c: job(c, cell), grid())
        hints = {c: (r['d1'], r['d2']) for c, r, _ in r1}
        res = pmap(lambda c: job(c, cell, hints[c]), grid()); plots(res, cell)
        save_met(cell, [(c, r) for c, r, _ in res])
        for c, r, _ in res: print(cell, c, {k: (round(x, 3) if isinstance(x, float) else x) for k, x in r.items()})
