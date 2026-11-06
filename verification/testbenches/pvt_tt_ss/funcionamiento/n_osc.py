from nf import *
CELL = 'wd_oscillater'
GR = {'BIAS': ['x1'], 'CINF': ['x2'], 'CSUP': ['x3'], 'DIV': ['XR1'], 'DRV': ['x6'], 'LOG': ['x4', 'x5', 'x7']}
GNAME = {'BIAS': 'bias', 'CINF': 'comp_inf', 'CSUP': 'comp_sup', 'DIV': 'divisor R1–R3', 'DRV': 'buf_1 → R4·C4', 'LOG': 'latch NOR + buf_4 (CLK)'}
TEND = 650e-6; TW = 300e-6   # régimen: desde 300 µs


def net(c, tmax, edges=None):
    m, t, v = c
    vbk = ''
    if edges:
        vbk = 'VBK BK 0 PWL(' + bk_pwl(edges, pre=200e-9, post=200e-9, dt=50e-12) + ')\nRBK BK 0 1k'
    am = ' '.join(f'i(v.xo.vam_{g.lower()})' for g in GR)
    sv = f'v(vdd) v(clk) v(xo.vc) v(xo.vh) v(xo.vl) v(xo.set) v(xo.rst) v(xo.drive) i(vdd) {am}'
    return header(m, t, v, 'wd_oscillater: funcionamiento, consumo por bloque y flancos') + amm(cellnet(CELL), CELL, GR) + f"""
XO CLK VDD VSS wd_oscillater
CCLK CLK 0 200f
VDD VDD 0 PWL(0 0 10u {v})
VSS VSS 0 0
{vbk}
""" + ctl([f'save {sv}', f'tran 10n {TEND*1e6:.0f}u {"290u" if edges else "0"} {tmax}', f'wrdata @OUT@ {sv}'])


def analyze(c, d):
    m, t, v = c
    tt = d['time']; vc = d['vxovc']; clk = d['vclk']; vh = d['vxovh']; vl = d['vxovl']; idd = -d['ivdd']
    cu = cross(tt, clk, v / 2, True, TW); cd = cross(tt, clk, v / 2, False, TW)
    if len(cu) < 3 or len(cd) < 2: return dict(ok=False)
    T = float(np.mean(np.diff(cu))); duty = float(np.mean([(first(cd[cd > a]) - a) / T for a in cu[:-1]]))
    k = (tt > cu[0]) & (tt < cu[0] + T)
    ovh = float((vc[k] - vh[k]).max()); ovl = float((vl[k] - vc[k]).max())
    t0, t1 = cu[0], cu[0] + 2 * T
    blk = {g: avg(tt, d[[n for n in d.dtype.names if n.endswith('vam_' + g.lower())][0]], t0, t1) for g in GR}
    tsu = first(cross(tt, clk, v / 2, True, 12e-6))
    r = dict(T_us=T * 1e6, f_khz=1e-3 / T, err_pct=(T / 100e-6 - 1) * 100, duty_pct=duty * 100,
             tsu_us=tsu * 1e6, ov_h_mv=ovh * 1e3, ov_l_mv=ovl * 1e3,
             swing_v=float(vc[k].max() - vc[k].min()),
             idd_ua=avg(tt, idd, t0, t1) * 1e6, ipk_ua=float(idd[tt > TW].max() * 1e6),
             **{f'i_{g.lower()}_ua': x * 1e6 for g, x in blk.items()})
    # el latch no debe quedar a medio camino (artefacto numérico con paso grueso: corriente estática de µA en la lógica)
    r['ok'] = bool(80 < r['T_us'] < 120 and 45 < r['duty_pct'] < 55 and r['i_log_ua'] < 0.05)
    return r


DIGNET = """* camino digital del oscilador (mismas celdas y cargas que en wd_oscillater)
x4 NCHG SET CHG VDD VSS sg13g2_nor2_1
x5 CHG RST NCHG VDD VSS sg13g2_nor2_1
x6 DRIVE CHG VDD VSS sg13g2_buf_1
x7 CLK CHG VDD VSS sg13g2_buf_4
XR4 VC DRIVE VSS rppd w=0.5e-6 l=175.5e-6 m=1 b=15 mm_ok=1
XC4 VC VSS cap_cmim w=64.0e-6 l=64.0e-6 m=8 mm_ok=1
CCLK CLK 0 200f
"""
TS, TR = 25e-9, 50e-9   # SET↑ y RST↑ (pulsos de 10 ns con flancos de 1 ns, como la salida de los comparadores)


def dig_job(c):
    m, t, v = c; tg = f'oscdig_{m}_{t}_{v}'
    n = header(m, t, v, 'wd_oscillater: latch NOR + buffers (flancos de CLK)') + DIGNET + f"""
VDD VDD 0 {v}
VSS VSS 0 0
VSET SET 0 PWL(0 0 {TS} 0 {TS+1e-9} {v} {TS+10e-9} {v} {TS+11e-9} 0)
VRST RST 0 PWL(0 0 3e-9 0 4e-9 {v} 12e-9 {v} 13e-9 0 {TR} 0 {TR+1e-9} {v} {TR+10e-9} {v} {TR+11e-9} 0)
""" + ctl(['tran 1p 80n 0 5p', f'wrdata {tg}.txt v(set) v(rst) v(chg) v(clk) v(drive) i(vdd)'])
    run2(n, tg); d = ld(tg); tt = d['time']; clk = d['vclk']; idd = -d['ivdd']
    r10, r50, r90 = edge_times(tt, clk, v, True, TS, TR); f90, f50, f10 = edge_times(tt, clk, v, False, TR)
    il = avg(tt, idd, 40e-9, 49e-9)
    r = dict(clk_tr_ps=(r90 - r10) * 1e12, clk_tf_ps=(f10 - f90) * 1e12, dly_set_ps=(r50 - TS - 0.5e-9) * 1e12, dly_rst_ps=(f50 - TR - 0.5e-9) * 1e12,
             q_rise_fc=(integ(tt, idd, TS, TS + 8e-9) - il * 8e-9) * 1e15, q_fall_fc=(integ(tt, idd, TR, TR + 8e-9) - il * 8e-9) * 1e15,
             ipk_dig_ua=float(idd.max() * 1e6))
    return r, d


def job(c):
    m, t, v = c
    for tm in ['0.1u', '0.07u', '0.13u']:
        tg = f'osc_{m}_{t}_{v}_{tm}'
        log = run2(net(c, tm).replace('@OUT@', f'{tg}.txt'), tg)
        try: d = ld(tg)
        except Exception: continue
        r = analyze(c, d)
        if r.get('ok'): break
    r['tmax'] = tm
    rd, dd = dig_job(c); r.update(rd)
    return c, r, (d, dd)


def plots(res):
    for m in CORNERS:
        rr = [(c, r, d) for c, r, d in res if c[0] == m]
        # 1) diagrama temporal alineado al flanco de subida de CLK
        fig, ax = plt.subplots(4, 1, figsize=(10, 8.4), sharex=True, gridspec_kw=dict(height_ratios=[1.6, 0.8, 0.8, 0.8]))
        for (mm, t, v), r, (d, _d2) in rr:
            s = P.style(t, v); tt = d['time']
            t0 = first(cross(tt, d['vclk'], v / 2, True, TW)); k = (tt > t0 - 15e-6) & (tt < t0 + 215e-6); x = (tt[k] - t0) * 1e6
            ax[0].plot(x, d['vxovc'][k], **s)
            ax[0].plot(x, d['vxovh'][k], **dict(s, linewidth=0.9, alpha=0.5)); ax[0].plot(x, d['vxovl'][k], **dict(s, linewidth=0.9, alpha=0.5))
            ax[1].plot(x, d['vxoset'][k], **s); ax[2].plot(x, d['vxorst'][k], **s); ax[3].plot(x, d['vclk'][k], **s)
        ax[0].set(title='VC (capacitor de temporización) entre VL = VDD/3 y VH = 2·VDD/3 (trazo tenue)', ylabel='V')
        ax[1].set(title='SET (comp_inf: VC < VL)', ylabel='V'); ax[2].set(title='RST (comp_sup: VC > VH)', ylabel='V')
        ax[3].set(title='CLK (buf_4, carga 200 fF)', ylabel='V', xlabel='t − flanco de subida de CLK (µs)')
        ax[0].set_title(ax[0].get_title(), loc='left', fontsize=10); ax[0].title.set_text('')
        ax[0].set_title('VC entre VL = VDD/3 y VH = 2·VDD/3 (tenue)', loc='left')
        P.legend(ax[0], loc='lower right', ncol=6, bbox_to_anchor=(1.0, 1.0))
        suptitle(fig, f'wd_oscillater · mos_{m} · funcionamiento en régimen (2 períodos)', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'Período {min(r["T_us"] for r in rr0):.2f}–{max(r["T_us"] for r in rr0):.2f} µs (error {min(r["err_pct"] for r in rr0):+.2f} … {max(r["err_pct"] for r in rr0):+.2f} % vs 100 µs) · '
                   f'duty {min(r["duty_pct"] for r in rr0):.1f}–{max(r["duty_pct"] for r in rr0):.1f} % · excursión de VC {min(r["swing_v"] for r in rr0):.3f}–{max(r["swing_v"] for r in rr0):.3f} V')
        P.save(fig, f'{G}/wd_oscillater/{m}/osc_{m}_diagrama_temporal.png')
        # 2) consumo
        fig = plt.figure(figsize=(11.5, 7.4)); gs = fig.add_gridspec(2, 1, height_ratios=[1, 1.15], hspace=0.42)
        a0 = fig.add_subplot(gs[0]); a1 = fig.add_subplot(gs[1])
        for (mm, t, v), r, (d, _d2) in rr:
            a0.plot(d['time'] * 1e6, -d['ivdd'] * 1e6, **dict(P.style(t, v), linewidth=1.1))
        a0.set(xlabel='t (µs)', ylabel='µA (escala log)', yscale='log', ylim=(1, None)); a0.set_title('I_DD total: arranque y régimen', loc='left')
        P.legend(a0, loc='lower right', ncol=6, bbox_to_anchor=(1.0, 1.0))
        lab = []; bot = np.zeros(len(rr))
        for j, g in enumerate(GR):
            vals = np.array([r[f'i_{g.lower()}_ua'] for _, r, _ in rr])
            a1.bar(range(len(rr)), vals, bottom=bot, color=CAT[j], width=0.62, edgecolor=P.SURF, linewidth=1.2, label=GNAME[g])
            bot += vals
        for i, ((mm, t, v), r, d) in enumerate(rr):
            a1.text(i, bot[i] + 0.25, f'{r["idd_ua"]:.1f}', ha='center', fontsize=8.5, color=P.INK)
        a1.set_xticks(range(len(rr)), [f'{t} °C\n{v:.2f} V' for (mm, t, v), _, _ in rr], fontsize=8.5)
        a1.set(title='Consumo medio por bloque en régimen (promedio de 2 períodos)', ylabel='µA', ylim=(0, bot.max() * 1.15)); a1.grid(axis='x', visible=False)
        a1.legend(loc='upper left', ncol=3, fontsize=8.5)
        suptitle(fig, f'wd_oscillater · mos_{m} · consumo (rampa de VDD de 10 µs, CLK con 200 fF)', y=0.98)
        P.save(fig, f'{G}/wd_oscillater/{m}/osc_{m}_consumo.png')
        # 3) VC frente a los umbrales alrededor de cada conmutación (escala de µs)
        fig, ax = plt.subplots(2, 2, figsize=(10.5, 5.8), sharex=True, gridspec_kw=dict(height_ratios=[1.3, 1]))
        for (mm, t, v), r, (d, _dd) in rr:
            s = P.style(t, v); tt = d['time']; vc = d['vxovc']
            for j, (sig, cmp_, rising) in enumerate(((vc - d['vxovh'], d['vxorst'], False), (d['vxovl'] - vc, d['vxoset'], True))):
                b = first(cross(tt, d['vclk'], v / 2, rising, TW + 100e-6))
                k = (tt > b - 1.5e-6) & (tt < b + 1.5e-6); x = (tt[k] - b) * 1e6
                ax[0, j].plot(x, sig[k] * 1e3, **s); ax[1, j].plot(x, cmp_[k] / v, **s)
        ax[0, 0].set(title='VC − VH alrededor de CLK↓ (fin de la carga)', ylabel='mV'); ax[0, 1].set(title='VL − VC alrededor de CLK↑ (fin de la descarga)')
        ax[1, 0].set(ylabel='RST / VDD', xlabel='t − CLK↓ (µs)'); ax[1, 1].set(ylabel='SET / VDD', xlabel='t − CLK↑ (µs)')
        for a in ax.flat: a.axvline(0, color=P.INK2, lw=0.7, ls=(0, (2, 2)))
        for a in ax[0]: a.axhline(0, color=P.INK2, lw=0.7)
        P.legend(ax[0, 0], loc='lower left', ncol=2)
        suptitle(fig, f'wd_oscillater · mos_{m} · disparo de los comparadores y sobrepaso de VC', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'Sobrepaso máximo de VC: {min(r["ov_h_mv"] for r in rr0):+.1f} … {max(r["ov_h_mv"] for r in rr0):+.1f} mV sobre VH y {min(r["ov_l_mv"] for r in rr0):+.1f} … {max(r["ov_l_mv"] for r in rr0):+.1f} mV bajo VL '
                   '(retardo del comparador × pendiente de VC). RST/SET son pulsos cortos: el latch los absorbe y VC se aleja del umbral.')
        P.save(fig, f'{G}/wd_oscillater/{m}/osc_{m}_disparo_comparadores.png')
        # 4) flancos de CLK (camino digital con SET/RST de 1 ns)
        fig, ax = plt.subplots(2, 2, figsize=(10.5, 5.6), sharex='col', gridspec_kw=dict(height_ratios=[1.2, 1]))
        for (mm, t, v), r, (_d, d) in rr:
            s = P.style(t, v); tt = d['time']
            for j, (t0, key) in enumerate(((TS + 0.5e-9, 'vset'), (TR + 0.5e-9, 'vrst'))):
                k = (tt > t0 - 0.4e-9) & (tt < t0 + 1.6e-9); x = (tt[k] - t0) * 1e12
                ax[0, j].plot(x, d[key][k] / v, **dict(s, linewidth=1.0, alpha=0.45)); ax[0, j].plot(x, d['vclk'][k] / v, **s)
                ax[1, j].plot(x, -d['ivdd'][k] * 1e6, **s)
        ax[0, 0].set(title='SET↑ → CLK↑', ylabel='V / VDD'); ax[0, 1].set(title='RST↑ → CLK↓')
        ax[1, 0].set(ylabel='I_DD (µA)', xlabel='t − 50 % de SET (ps)'); ax[1, 1].set(xlabel='t − 50 % de RST (ps)')
        ax[0, 0].text(0.03, 0.88, 'tenue: SET', transform=ax[0, 0].transAxes, fontsize=8, color=P.INK2)
        ax[0, 1].text(0.03, 0.88, 'tenue: RST', transform=ax[0, 1].transAxes, fontsize=8, color=P.INK2)
        P.legend(ax[0, 1], loc='center right', ncol=1)
        suptitle(fig, f'wd_oscillater · mos_{m} · latch NOR + buf_4: retardos y flancos de CLK (200 fF)', y=1.0)
        fig.tight_layout()
        rr0 = [r for _, r, _ in rr]
        P.subtitle(fig, f'Banco aparte con las mismas celdas y cargas (x4–x7, R4·C4, 200 fF) y SET/RST ideales de 1 ns: el paso de simulación del oscilador completo no resuelve flancos de ps.\n'
                   f'SET→CLK↑ {min(r["dly_set_ps"] for r in rr0):.0f}–{max(r["dly_set_ps"] for r in rr0):.0f} ps · RST→CLK↓ {min(r["dly_rst_ps"] for r in rr0):.0f}–{max(r["dly_rst_ps"] for r in rr0):.0f} ps · '
                   f't_r {min(r["clk_tr_ps"] for r in rr0):.0f}–{max(r["clk_tr_ps"] for r in rr0):.0f} ps · t_f {min(r["clk_tf_ps"] for r in rr0):.0f}–{max(r["clk_tf_ps"] for r in rr0):.0f} ps (10–90 %) · '
                   f'carga tomada de VDD por ciclo de CLK {min(r["q_rise_fc"] + r["q_fall_fc"] for r in rr0):.0f}–{max(r["q_rise_fc"] + r["q_fall_fc"] for r in rr0):.0f} fC')
        P.save(fig, f'{G}/wd_oscillater/{m}/osc_{m}_flancos_CLK.png')


if __name__ == '__main__' and len(sys.argv) > 1 and sys.argv[1] == 'replot':
    Mt = json.load(open(f'{MET}/{CELL}.json'))
    plots([(tuple(c), r, (ld(f'osc_{c[0]}_{c[1]}_{c[2]}_{r["tmax"]}'), ld(f'oscdig_{c[0]}_{c[1]}_{c[2]}'))) for c, r in Mt]); sys.exit()
if __name__ == '__main__':
    res = pmap(job, grid()); plots(res)
    save_met(CELL, [(c, r) for c, r, _ in res])
    for c, r, _ in res: print(c, {k: (round(x, 2) if isinstance(x, float) else x) for k, x in r.items()})
