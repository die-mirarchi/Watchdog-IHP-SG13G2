from nf import *
T = 100e-6
RISE = [50e-6 + k * T for k in range(8)]          # flancos de subida de CLK (50 % de la fuente ideal + ~0,1 ns del buffer)
FALL = [100e-6 + k * T for k in range(7)]
TEND = 720e-6
IN_UP, IN_DN = 120e-6, 520e-6                      # a mitad de ciclo
CFG = {
    'wd_reset_sync': dict(inst='XDUT IN CLK OUT VDD VSS wd_reset_sync', load='COUT OUT 0 100f',
                          sig=['v(clk)', 'v(in)', 'v(xdut.p1)', 'v(out)'], names=['CLK', 'POR_RAW_N', 'P1', 'POR_B'],
                          porb=None, inp='POR_RAW_N', mid='P1', outp='POR_B', ext=['v(xdut.p1_n)']),
    'EN_INPUT': dict(inst='XDUT PORB CLK MID IN OUT VDD VSS EN_INPUT', load='COUT OUT 0 10f\nCMID MID 0 10f',
                     sig=['v(clk)', 'v(in)', 'v(xdut.en_meta)', 'v(mid)', 'v(xdut.hist)', 'v(out)'], names=['CLK', 'EN', 'EN_META', 'SYNC', 'HIST', 'EDGE'],
                     porb=True, inp='EN', mid='SYNC', outp='EDGE'),
    'WDI_INPUT': dict(inst='XDUT PORB CLK IN OUT VDD VSS WDI_INPUT', load='COUT OUT 0 10f',
                      sig=['v(clk)', 'v(in)', 'v(xdut.wdi_meta)', 'v(xdut.wdi_sync)', 'v(xdut.hist)', 'v(out)'], names=['CLK', 'WDI_IN', 'WDI_META', 'WDI_SYNC', 'HIST', 'WDI_EDGE'],
                      porb=True, inp='WDI_IN', mid='WDI_SYNC', outp='WDI_EDGE'),
}


def job(c, cell):
    m, t, v = c; tg = f'{cell}_{m}_{t}_{v}'; C = CFG[cell]
    if cell == 'wd_reset_sync':
        vin = f'VIN IN 0 PWL(0 0 {IN_UP} 0 {IN_UP+1e-9} {v} 420e-6 {v} 420.001e-6 0 {IN_DN} 0 {IN_DN+1e-9} {v})'
        edges_in = [IN_UP, 420e-6, IN_DN]
    else:
        vin = f'VIN IN 0 PWL(0 0 {IN_UP} 0 {IN_UP+1e-9} {v} {IN_DN} {v} {IN_DN+1e-9} 0)'
        edges_in = [IN_UP, IN_DN]
    porb = f'VPB PORB 0 PWL(0 0 20u 0 20.001u {v})' if C['porb'] else ''
    sig = ' '.join(C['sig'])
    n = header(m, t, v, f'{cell}: consumo, retardos y flancos') + cellnet(cell) + f"""
* DUT en VDD (medido); buffer de reloj en VDDCK (no se mide)
VDD VDD 0 {v}
VDDCK VDDCK 0 {v}
VSS VSS 0 0
VCK CKI 0 PULSE(0 {v} 50u 2n 2n 50u 100u)
XCKB CLK CKI VDDCK VSS sg13g2_buf_4
CCLK CLK 0 200f
{porb}
{vin}
{C['inst']}
{C['load']}
* VBK: sin efecto eléctrico; pasos de 25 ps alrededor de flancos conocidos (evita el artefacto del FF)
VBK BK 0 PWL({bk_pwl(RISE + FALL + edges_in, pre=1e-9, post=4e-9, dt=25e-12)})
RBK BK 0 1k
""" + ctl([f'tran 1n {TEND*1e6:.0f}u 0 100n', f'wrdata {tg}.txt {sig} i(vdd)'])
    log = run2(n, tg); d = ld(tg)
    return c, analyze(c, cell, d, 'aborted' in log), d


def col(d, s):
    return d[s.replace('(', '').replace(')', '').replace('.', '')]


def analyze(c, cell, d, ab=False):
    m, t, v = c; C = CFG[cell]
    tt = d['time']; clk = d['vclk']; out = col(d, C['sig'][-1]); mid = col(d, 'v(mid)' if cell == 'EN_INPUT' else C['sig'][2] if cell == 'wd_reset_sync' else C['sig'][3])
    idd = -d['ivdd']
    ck = lambda e: first(cross(tt, clk, v / 2, True, e - 2e-9, e + 3e-9))
    if cell == 'wd_reset_sync':
        e_mid, e_out = RISE[1], RISE[2]       # P1 sube en 150 µs, POR_B en 250 µs
    else:
        e_mid, e_out = RISE[2], RISE[2]       # SYNC y EDGE suben en 250 µs
    tm = first(cross(tt, mid, v / 2, True, e_mid - 2e-9, e_mid + 5e-9)) - ck(e_mid)
    o10, o50, o90 = edge_times(tt, out, v, True, e_out - 2e-9, e_out + 10e-9); to = o50 - ck(e_out)
    r = dict(t_clk_mid_ps=tm * 1e12, t_clk_out_ps=to * 1e12, out_tr_ps=(o90 - o10) * 1e12)
    if cell == 'wd_reset_sync':
        f90, f50, f10 = edge_times(tt, out, v, False, 420e-6, 421e-6)
        r.update(t_assert_ps=(f50 - 420.0005e-6) * 1e12, out_tf_ps=(f10 - f90) * 1e12)
        quiet = (262e-6, 298e-6); per = (RISE[2] + 20e-9, RISE[3] + 20e-9)   # período sin cambios de salida
    else:
        f90, f50, f10 = edge_times(tt, out, v, False, RISE[3] - 2e-9, RISE[3] + 10e-9)
        r.update(t_clk_outfall_ps=(f50 - ck(RISE[3])) * 1e12, out_tf_ps=(f10 - f90) * 1e12)
        quiet = (262e-6, 298e-6); per = (RISE[4] - 5e-9, RISE[5] - 5e-9)
    il = avg(tt, idd, *quiet)
    qr = integ(tt, idd, RISE[4] - 2e-9, RISE[4] + 20e-9) - il * 22e-9
    qf = integ(tt, idd, FALL[4] - 2e-9, FALL[4] + 20e-9) - il * 22e-9
    r.update(ileak_pa=il * 1e12, iavg_na=avg(tt, idd, *per) * 1e9, q_rise_fc=qr * 1e15, q_fall_fc=qf * 1e15,
             ipk_ua=float(np.abs(idd).max() * 1e6), abort=ab)
    r['ok'] = bool(all(np.isfinite([r['t_clk_mid_ps'], r['t_clk_out_ps']])) and 0 < r['t_clk_out_ps'] < 2000)
    return r


def plots(res, cell):
    C = CFG[cell]
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        fig = plt.figure(figsize=(11.5, 7.6)); gs = fig.add_gridspec(2, 3, height_ratios=[1, 1.15], hspace=0.42, wspace=0.28)
        a0 = fig.add_subplot(gs[0, :]); b = [fig.add_subplot(gs[1, j]) for j in range(3)]
        e_out = RISE[2]; e2 = RISE[3] if cell != 'wd_reset_sync' else None
        for (mm, t, v), r, d in rr:
            s = P.style(t, v); tt = d['time']; idd = -d['ivdd']
            a0.plot(tt * 1e6, np.maximum(np.abs(idd), 1e-13) * 1e6, **dict(s, linewidth=1.0))
            ck0 = first(cross(tt, d['vclk'], v / 2, True, e_out - 2e-9, e_out + 3e-9))
            k = (tt > ck0 - 0.3e-9) & (tt < ck0 + 1.5e-9); x = (tt[k] - ck0) * 1e12
            b[0].plot(x, d['vclk'][k] / v, **dict(s, linewidth=1.0, alpha=0.5)); b[0].plot(x, col(d, C['sig'][-1])[k] / v, **s)
            if cell == 'wd_reset_sync':
                tf = 420.0005e-6; k2 = (tt > tf - 0.6e-9) & (tt < tf + 1.3e-9); x2 = (tt[k2] - tf) * 1e12
                b[1].plot(x2, col(d, 'v(in)')[k2] / v, **dict(s, linewidth=1.0, alpha=0.5)); b[1].plot(x2, col(d, 'v(out)')[k2] / v, **s)
            else:
                ck1 = first(cross(tt, d['vclk'], v / 2, True, e2 - 2e-9, e2 + 3e-9)); k2 = (tt > ck1 - 0.3e-9) & (tt < ck1 + 1.5e-9); x2 = (tt[k2] - ck1) * 1e12
                b[1].plot(x2, d['vclk'][k2] / v, **dict(s, linewidth=1.0, alpha=0.5)); b[1].plot(x2, col(d, C['sig'][-1])[k2] / v, **s)
            b[2].plot(x, idd[k] * 1e6, **s)
        a0.set(yscale='log', xlabel='t (µs)', ylabel='µA (log)', ylim=(1e-6, None)); a0.set_title('|I_DD| de la celda en el tiempo', loc='left')
        for e in (IN_UP, IN_DN) + ((420e-6,) if cell == 'wd_reset_sync' else ()):
            a0.axvline(e * 1e6, color=P.INK2, lw=0.7, ls=(0, (2, 2)))
        a0.text(IN_UP * 1e6 + 4, 2e-6, f'{C["inp"]} ↑', fontsize=8, color=P.INK2); a0.text(IN_DN * 1e6 + 4, 2e-6, f'{C["inp"]} {"↑" if cell == "wd_reset_sync" else "↓"}', fontsize=8, color=P.INK2)
        if cell == 'wd_reset_sync': a0.text(424, 2e-6, 'POR_RAW_N ↓', fontsize=8, color=P.INK2)
        P.legend(a0, loc='lower right', ncol=6, bbox_to_anchor=(1.0, 1.0))
        b[0].set(title=f'CLK↑ → {C["outp"]}↑', xlabel='t − CLK 50 % (ps)', ylabel='V / VDD')
        b[1].set(title='POR_RAW_N↓ → POR_B↓ (asíncrono)' if cell == 'wd_reset_sync' else f'CLK↑ → {C["outp"]}↓ (fin del pulso)',
                 xlabel='t − POR_RAW_N 50 % (ps)' if cell == 'wd_reset_sync' else 't − CLK 50 % (ps)')
        b[2].set(title=f'I_DD en el flanco de {C["outp"]}↑', xlabel='t − CLK 50 % (ps)', ylabel='µA')
        b[0].text(0.03, 0.9, 'tenue: CLK' if cell != 'wd_reset_sync' else 'tenue: CLK', transform=b[0].transAxes, fontsize=8, color=P.INK2)
        b[1].text(0.55, 0.45, 'tenue: ' + ('POR_RAW_N' if cell == 'wd_reset_sync' else 'CLK'), transform=b[1].transAxes, fontsize=8, color=P.INK2)
        load = '100 fF' if cell == 'wd_reset_sync' else '10 fF'
        suptitle(fig, f'{cell} · mos_{m} · consumo y flancos (DUT en fuente aparte; CLK 10 kHz con buf_4; carga de {C["outp"]} {load})', y=0.99)
        rr0 = [r for _, r, _ in rr]
        g = lambda k, f='{:.0f}': f'{f.format(min(r[k] for r in rr0))}–{f.format(max(r[k] for r in rr0))}'
        extra = f't_aserción {g("t_assert_ps")} ps' if cell == 'wd_reset_sync' else f'CLK→{C["outp"]}↓ {g("t_clk_outfall_ps")} ps'
        P.subtitle(fig, f'CLK→{C["mid"]} {g("t_clk_mid_ps")} ps · CLK→{C["outp"]}↑ {g("t_clk_out_ps")} ps · {extra} · t_r {g("out_tr_ps")} ps · t_f {g("out_tf_ps")} ps · '
                   f'fuga {g("ileak_pa")} pA · carga por flanco de CLK ↑ {g("q_rise_fc", "{:.1f}")} fC, ↓ {g("q_fall_fc", "{:.1f}")} fC · I_DD medio a 10 kHz {g("iavg_na", "{:.2f}")} nA')
        P.save(fig, f'{G}/{cell}/{m}/{cell}_{m}_consumo_y_flancos.png'.replace('wd_reset_sync_', 'rsync_'))


if __name__ == '__main__' and len(sys.argv) > 1 and sys.argv[1] == 'replot':
    for cell in (sys.argv[2:] or list(CFG)):
        res = []
        for c in grid():
            d = ld(f'{cell}_{c[0]}_{c[1]}_{c[2]}'); res.append((c, analyze(c, cell, d), d))
        plots(res, cell); save_met(cell, [(c, r) for c, r, _ in res])
    sys.exit()
if __name__ == '__main__':
    cells = sys.argv[1:] or list(CFG)
    for cell in cells:
        res = pmap(lambda c: job(c, cell), grid()); plots(res, cell)
        save_met(cell, [(c, r) for c, r, _ in res])
        for c, r, _ in res: print(cell, c, {k: (round(x, 1) if isinstance(x, float) else x) for k, x in r.items()})
