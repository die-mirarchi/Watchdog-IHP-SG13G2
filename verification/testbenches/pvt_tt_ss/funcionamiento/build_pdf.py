"""Resumen de validación tt/ss en PDF (tablas de valores clave) — reportlab."""
import json, os, sys, datetime
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from nf import VAL, MET
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table, TableStyle,
                                PageBreak, KeepTogether, Image, CondPageBreak)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

FD = '/usr/share/fonts/truetype/dejavu/'
pdfmetrics.registerFont(TTFont('DV', FD + 'DejaVuSans.ttf'))
pdfmetrics.registerFont(TTFont('DVB', FD + 'DejaVuSans-Bold.ttf'))
pdfmetrics.registerFont(TTFont('DVC', FD + 'DejaVuSansCondensed.ttf'))
pdfmetrics.registerFont(TTFont('DVCB', FD + 'DejaVuSansCondensed-Bold.ttf'))
pdfmetrics.registerFontFamily('DV', normal='DV', bold='DVB')

OUTPDF = sys.argv[1] if len(sys.argv) > 1 else f'{VAL}/Resumen_validacion_tt_ss.pdf'
os.makedirs(os.path.dirname(OUTPDF), exist_ok=True)
INK = colors.HexColor('#0b0b0b'); INK2 = colors.HexColor('#52514e'); LINE = colors.HexColor('#d9d8d3')
HEAD = colors.HexColor('#f1f0ec'); BAND = colors.HexColor('#f8f7f4'); ACC = colors.HexColor('#2a78d6'); WARN = colors.HexColor('#b26b00')

# ------------------------------------------------------------------ datos
def lm(n): return {tuple(c): r for c, r in json.load(open(f'{MET}/{n}.json'))}
def lo(n): return {tuple(c): r for c, r in json.load(open(f'{VAL}/{n}.json'))}
M = {k: lm(k) for k in ['bias', 'schmitt', 'comp_sup', 'comp_inf', 'wd_oscillater', 'wd_por', 'wd_reset_sync', 'EN_INPUT', 'WDI_INPUT', 'integracion']}
A = {k: {tuple(c): r for c, r in v} for k, v in json.load(open(f'{VAL}/res_analog.json')).items()}
O = dict(osc=lo('res_osc'), por=lo('res_por'), rsync=lo('res_rsync'), EN=lo('res_EN_INPUT'), WDI=lo('res_WDI_INPUT'), integ=lo('res_integ'))
CORN = ['tt', 'ss']; TEMPS = [-40, 27, 85]; VDDS = [1.08, 1.2, 1.32]
CONDS = [(m, t, v) for m in CORN for t in TEMPS for v in VDDS]
TYP = ('tt', 27, 1.2)


def num(x, nd=2):
    if x is None or (isinstance(x, float) and not np.isfinite(x)): return '—'
    s = f'{x:.{nd}f}'.replace('.', ',')
    return s.replace('-', '−')


def rng(f, corner, nd):
    vals = [f(c) for c in CONDS if c[0] == corner]
    vals = [x for x in vals if x is not None and np.isfinite(x)]
    if not vals: return '—'
    a, b = min(vals), max(vals)
    return num(a, nd) if abs(a - b) < 0.5 * 10 ** (-nd) else f'{num(a, nd)} … {num(b, nd)}'


# ------------------------------------------------------------------ estilos
S = dict(
    h1=ParagraphStyle('h1', fontName='DVB', fontSize=17, leading=21, textColor=INK, spaceAfter=4),
    sub=ParagraphStyle('sub', fontName='DV', fontSize=9, leading=12.5, textColor=INK2, spaceAfter=8),
    h2=ParagraphStyle('h2', fontName='DVB', fontSize=12.5, leading=16, textColor=INK, spaceBefore=10, spaceAfter=5),
    h3=ParagraphStyle('h3', fontName='DVB', fontSize=10, leading=13, textColor=INK, spaceBefore=8, spaceAfter=3),
    p=ParagraphStyle('p', fontName='DV', fontSize=8.6, leading=12, textColor=INK, spaceAfter=5),
    note=ParagraphStyle('note', fontName='DV', fontSize=7.6, leading=10, textColor=INK2, spaceAfter=4),
    cell=ParagraphStyle('cell', fontName='DVC', fontSize=7.6, leading=9.4, textColor=INK),
    cellb=ParagraphStyle('cellb', fontName='DVCB', fontSize=7.6, leading=9.4, textColor=INK),
    cellh=ParagraphStyle('cellh', fontName='DVCB', fontSize=7.4, leading=9, textColor=INK2),
    grp=ParagraphStyle('grp', fontName='DVB', fontSize=8.2, leading=10, textColor=ACC),
)


def P_(t, st='cell'): return Paragraph(t, S[st])


def table(rows, widths, head_rows=1, group_rows=(), zebra=True, align_right_from=None):
    t = Table(rows, colWidths=widths, repeatRows=head_rows)
    st = [('FONT', (0, 0), (-1, -1), 'DVC', 7.6), ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
          ('BACKGROUND', (0, 0), (-1, head_rows - 1), HEAD), ('LINEBELOW', (0, head_rows - 1), (-1, head_rows - 1), 0.8, INK2),
          ('LINEBELOW', (0, head_rows), (-1, -1), 0.25, LINE), ('TOPPADDING', (0, 0), (-1, -1), 2.2), ('BOTTOMPADDING', (0, 0), (-1, -1), 2.2),
          ('LEFTPADDING', (0, 0), (-1, -1), 3.5), ('RIGHTPADDING', (0, 0), (-1, -1), 3.5)]
    for r in group_rows:
        st += [('SPAN', (0, r), (-1, r)), ('BACKGROUND', (0, r), (-1, r), colors.white), ('LINEABOVE', (0, r), (-1, r), 0.8, INK2), ('TOPPADDING', (0, r), (-1, r), 5)]
    if align_right_from is not None:
        st += [('ALIGN', (align_right_from, head_rows), (-1, -1), 'RIGHT')]
    t.setStyle(TableStyle(st)); return t


# ------------------------------------------------------------------ tabla resumen
def g(d, k, sc=1.0):
    return lambda c: (d[c][k] * sc if (c in d and k in d[c] and d[c][k] is not None) else None)


rs = O['rsync']
def lat_rs(c): return [rs[c][f'd{s}'] for s in range(8)]
SUM = []   # (grupo, [(parámetro, unidad, f, nd, criterio)])
SUM.append(('bias — fuente de corriente referida a resistencia', [
    ('I_REF (XM1, diodo NMOS)', 'µA', g(M['bias'], 'iref_ua'), 2, ''),
    ('I_OUT (espejo XM3 → XM2)', 'µA', g(M['bias'], 'iout_ua'), 2, ''),
    ('I_DD de la celda', 'µA', g(M['bias'], 'idd_ua'), 2, ''),
    ('VBN', 'V', g(M['bias'], 'vbn'), 3, '0,3–0,7'),
    ('V_SG del diodo PMOS (VDD − VBP)', 'V', g(M['bias'], 'vsg'), 3, '0,3–0,75'),
    ('Error de copia del espejo (I_OUT/I_REF − 1)', '%', g(M['bias'], 'mirror_err_pct'), 1, ''),
    ('Regulación de línea de I_OUT', '%/V', g(M['bias'], 'line_pct_v'), 0, ''),
    ('Coeficiente térmico de I_OUT', 'ppm/°C', g(M['bias'], 'tc_ppm'), 0, ''),
    ('Establecimiento al 1 % (escalón de VDD de 100 ns)', 'µs', g(M['bias'], 'tset_us'), 2, ''),
]))
SUM.append(('schmitt — disparador (carga 10 fF)', [
    ('Umbral de subida V_T+', 'V', g(A['schmitt'], 'vt_plus'), 3, ''),
    ('Umbral de bajada V_T−', 'V', g(A['schmitt'], 'vt_minus'), 3, ''),
    ('Histéresis', 'mV', g(A['schmitt'], 'hyst_mv'), 0, '> 100'),
    ('Retardo t_pHL / t_pLH (entrada de 50 ps)', 'ps', None, 0, ''),
    ('Tiempo de bajada t_f / subida t_r (10–90 %)', 'ps', None, 0, ''),
    ('Pico de I_DD en DC (cortocircuito)', 'µA', g(M['schmitt'], 'ipk_dc_ua'), 1, ''),
    ('Fuga con IN = 0', 'pA', g(M['schmitt'], 'ileak_lo_pa'), 0, ''),
    ('Energía por ciclo completo', 'fJ', g(M['schmitt'], 'e_cycle_fj'), 1, ''),
]))
for cell, ref in (('comp_sup', 'VN = 2/3·VDD'), ('comp_inf', 'VP = 1/3·VDD')):
    SUM.append((f'{cell} — comparador ({ref}, bias real en fuente aparte, carga 10 fF)', [
        ('Offset de entrada', 'mV', g(A[cell], 'offset_mv'), 2, '|x| < 10'),
        ('Histéresis de disparo (barrido en ambos sentidos)', 'mV', lambda c, cell=cell: abs(A[cell][c]['trip_a_mv'] - A[cell][c]['trip_b_mv']), 2, '< 5'),
        ('Corriente de cola', 'µA', g(M[cell], 'itail_ua'), 2, ''),
        ('I_DD en reposo, OUT alto', 'µA', g(M[cell], 'idd_outhi_ua'), 2, ''),
        ('I_DD en reposo, OUT bajo', 'µA', g(M[cell], 'idd_outlo_ua'), 2, ''),
        ('Retardo OUT↑ (escalón de ±20 mV)', 'ns', g(M[cell], 'tpd_lh_us', 1e3), 0, ''),
        ('Retardo OUT↓ (escalón de ±20 mV)', 'ns', g(M[cell], 'tpd_hl_us', 1e3), 0, ''),
        ('t_r / t_f de OUT (10–90 %)', 'ns', None, 2, ''),
        ('Pico de I_DD al cruzar el umbral (DC)', 'µA', g(M[cell], 'ipk_dc_ua'), 1, ''),
    ]))
SUM.append(('wd_oscillater — oscilador de relajación (CLK con carga 200 fF)', [
    ('Período', 'µs', g(M['wd_oscillater'], 'T_us'), 2, '80–120'),
    ('Error de período respecto de 100 µs', '%', g(M['wd_oscillater'], 'err_pct'), 2, '± 20'),
    ('Ciclo de trabajo', '%', g(M['wd_oscillater'], 'duty_pct'), 1, '45–55'),
    ('Primer flanco de CLK desde el inicio de la rampa', 'µs', g(M['wd_oscillater'], 'tsu_us'), 1, '< 150'),
    ('Excursión de VC (VH − VL efectiva)', 'V', g(M['wd_oscillater'], 'swing_v'), 3, ''),
    ('Sobrepaso de VC sobre VH / bajo VL', 'mV', None, 1, ''),
    ('Retardo RST↑ → CLK↓ / SET↑ → CLK↑ (latch + buf_4)', 'ps', None, 0, ''),
    ('t_r / t_f de CLK (10–90 %)', 'ps', None, 0, ''),
    ('I_DD medio en régimen', 'µA', g(M['wd_oscillater'], 'idd_ua'), 2, ''),
    ('Pico de I_DD en un flanco de CLK (latch + buf_4)', 'µA', g(M['wd_oscillater'], 'ipk_dig_ua'), 0, ''),
    ('Carga tomada de VDD por ciclo de CLK (latch + buffers)', 'fC', lambda c: M['wd_oscillater'][c]['q_rise_fc'] + M['wd_oscillater'][c]['q_fall_fc'], 0, ''),
]))
SUM.append(('wd_por — detector de nivel + filtro RC', [
    ('VDD de liberación (rampa de 1 ms)', 'V', g(O['por'], 'va'), 3, '0,45–1,03'),
    ('VDD de aserción (bajada de 1 ms)', 'V', g(O['por'], 'vc'), 3, '0,45–1,03'),
    ('Umbral DC de VOK', 'V', g(M['wd_por'], 'vok_dc'), 3, ''),
    ('Margen hasta VDD mín. (1,08 V − liberación)', 'mV', lambda c: (1.08 - O['por'][c]['va']) * 1e3, 0, '> 50'),
    ('Retardo tras rampa de 1 µs (filtro R3·C1)', 'µs', g(O['por'], 'dd'), 2, '> 1'),
    ('Retardo tras corte de 10 µs', 'µs', g(O['por'], 'de'), 2, '≥ 0,8 × (1 µs)'),
    ('Liberación con rampa de 10 µs (desde t = 0)', 'µs', g(M['wd_por'], 't_rel_us'), 2, ''),
    ('t_r de POR_RAW_N/VDD (10–90 %, carga 10 fF)', 'ns', g(M['wd_por'], 'tr_ps', 1e-3), 2, ''),
    ('I_DD estático (POR liberado)', 'µA', g(O['por'], 'iua'), 2, '< 2'),
    ('Pico de I_DD durante el arranque', 'µA', g(M['wd_por'], 'ipk_ua'), 1, ''),
]))
SUM.append(('wd_reset_sync — sincronizador de reset (2 × dfrbp_1, POR_B con 100 fF)', [
    ('Latencia de liberación (8 fases de POR_RAW_N)', 'ciclos', None, 2, '1–2'),
    ('CLK↑ → P1↑', 'ps', g(M['wd_reset_sync'], 't_clk_mid_ps'), 0, ''),
    ('CLK↑ → POR_B↑', 'ps', g(M['wd_reset_sync'], 't_clk_out_ps'), 0, '< 20 ns'),
    ('POR_RAW_N↓ → POR_B↓ (asíncrono)', 'ps', g(M['wd_reset_sync'], 't_assert_ps'), 0, '< 100 ns'),
    ('t_r / t_f de POR_B (10–90 %)', 'ps', None, 0, ''),
    ('Fuga entre flancos', 'pA', g(M['wd_reset_sync'], 'ileak_pa'), 0, ''),
    ('Carga por flanco de CLK (↑ / ↓)', 'fC', None, 1, ''),
    ('I_DD medio a 10 kHz', 'nA', g(M['wd_reset_sync'], 'iavg_na'), 2, ''),
]))
for cell, k in (('EN_INPUT', 'EN'), ('WDI_INPUT', 'WDI')):
    o = 'EDGE' if cell == 'EN_INPUT' else 'WDI_EDGE'; s_ = 'SYNC' if cell == 'EN_INPUT' else 'WDI_SYNC'
    SUM.append((f'{cell} — sincronizador (2 FF) + detector de flanco ({o} con 10 fF)', [
        ('Latencia entrada → flanco (mitad de ciclo, ±5 ns del flanco)', 'ciclos', None, 2, '1–2'),
        (f'Ancho del pulso {o}', 'ciclos', lambda c, k=k: float(np.mean(O[k][c]['width_T'])), 4, '1'),
        (f'CLK↑ → {s_}↑', 'ps', g(M[cell], 't_clk_mid_ps'), 0, ''),
        (f'CLK↑ → {o}↑ / CLK↑ → {o}↓', 'ps', None, 0, ''),
        (f't_r / t_f de {o} (10–90 %)', 'ps', None, 0, ''),
        ('Fuga entre flancos', 'pA', g(M[cell], 'ileak_pa'), 0, ''),
        ('I_DD medio a 10 kHz', 'nA', g(M[cell], 'iavg_na'), 2, ''),
    ]))
SUM.append(('Integración wd_oscillater + wd_por + wd_reset_sync (FF en XSPICE)', [
    ('VDD al liberar POR_RAW_N (rampa de 1 ms)', 'V', g(O['integ'], 'vRC'), 3, ''),
    ('VDD al liberar POR_B (rampa de 1 ms)', 'V', g(O['integ'], 'vBC'), 3, 'ver § 3'),
    ('Latencia POR_RAW_N → POR_B (rampa de 10 µs)', 'ciclos', g(O['integ'], 'nTA'), 2, '1–3'),
    ('POR_B liberado desde el inicio de la rampa de 10 µs', 'µs', g(M['integracion'], 't_porb_A_us'), 0, ''),
    ('I_DD total en régimen (oscilador + POR)', 'µA', g(M['integracion'], 'i_tot_ua'), 2, ''),
]))

# filas con dos magnitudes "a / b"
PAIRS = {
    'Retardo t_pHL / t_pLH (entrada de 50 ps)': (g(M['schmitt'], 'tphl_ps'), g(M['schmitt'], 'tplh_ps')),
    'Tiempo de bajada t_f / subida t_r (10–90 %)': (g(M['schmitt'], 'tf_ps'), g(M['schmitt'], 'tr_ps')),
    'Sobrepaso de VC sobre VH / bajo VL': (g(M['wd_oscillater'], 'ov_h_mv'), g(M['wd_oscillater'], 'ov_l_mv')),
    'Retardo RST↑ → CLK↓ / SET↑ → CLK↑ (latch + buf_4)': (g(M['wd_oscillater'], 'dly_rst_ps'), g(M['wd_oscillater'], 'dly_set_ps')),
    't_r / t_f de CLK (10–90 %)': (g(M['wd_oscillater'], 'clk_tr_ps'), g(M['wd_oscillater'], 'clk_tf_ps')),
    't_r / t_f de POR_B (10–90 %)': (g(M['wd_reset_sync'], 'out_tr_ps'), g(M['wd_reset_sync'], 'out_tf_ps')),
    'Carga por flanco de CLK (↑ / ↓)': (g(M['wd_reset_sync'], 'q_rise_fc'), g(M['wd_reset_sync'], 'q_fall_fc')),
    'Latencia de liberación (8 fases de POR_RAW_N)': (lambda c: min(lat_rs(c)), lambda c: max(lat_rs(c))),
}


def pair_rows(grp_title, cell=None):
    pass


def fmt_cell(f, c, nd):
    x = f(c); return num(x, nd)


def build_summary():
    head = [P_('Parámetro', 'cellh'), P_('Unidad', 'cellh'), P_('Típico<br/>tt, 27 °C, 1,20 V', 'cellh'),
            P_('tt: mín … máx<br/>(−40/27/85 °C × 1,08/1,20/1,32 V)', 'cellh'), P_('ss: mín … máx', 'cellh'), P_('Criterio', 'cellh')]
    rows = [head]; groups = []
    for grp, items in SUM:
        groups.append(len(rows)); rows.append([P_(grp, 'grp'), '', '', '', '', ''])
        for (par, unit, f, nd, crit) in items:
            if f is None:
                key = par
                if key not in PAIRS:
                    # EN/WDI y comparadores: pares por celda
                    cell = grp.split(' ')[0]
                    if cell in ('EN_INPUT', 'WDI_INPUT') and par.startswith('Latencia'):
                        k = 'EN' if cell == 'EN_INPUT' else 'WDI'
                        fa = lambda c, k=k: min(O[k][c]['lat_T']); fb = lambda c, k=k: max(O[k][c]['lat_T'])
                    elif cell in ('EN_INPUT', 'WDI_INPUT') and par.startswith('CLK↑'):
                        fa, fb = g(M[cell], 't_clk_out_ps'), g(M[cell], 't_clk_outfall_ps')
                    elif cell in ('EN_INPUT', 'WDI_INPUT'):
                        fa, fb = g(M[cell], 'out_tr_ps'), g(M[cell], 'out_tf_ps')
                    else:  # comparadores
                        fa, fb = g(M[cell], 'tr_ps', 1e-3), g(M[cell], 'tf_ps', 1e-3)
                else:
                    fa, fb = PAIRS[key]
                typ = f'{num(fa(TYP), nd)} / {num(fb(TYP), nd)}'
                tt_ = f'{rng(fa, "tt", nd)} / {rng(fb, "tt", nd)}'; ss_ = f'{rng(fa, "ss", nd)} / {rng(fb, "ss", nd)}'
            else:
                typ = num(f(TYP), nd); tt_ = rng(f, 'tt', nd); ss_ = rng(f, 'ss', nd)
            rows.append([P_(par), P_(unit), P_(typ), P_(tt_), P_(ss_), P_(crit)])
    return table(rows, [57 * mm, 12 * mm, 27 * mm, 34 * mm, 34 * mm, 16 * mm], group_rows=groups)


# ------------------------------------------------------------------ consumo
def build_power():
    o = M['wd_oscillater']; p = M['wd_por']
    items = [('wd_oscillater · bias', lambda c: o[c]['i_bias_ua']), ('wd_oscillater · comp_inf', lambda c: o[c]['i_cinf_ua']),
             ('wd_oscillater · comp_sup', lambda c: o[c]['i_csup_ua']), ('wd_oscillater · divisor R1–R3', lambda c: o[c]['i_div_ua']),
             ('wd_oscillater · buf_1 → R4·C4', lambda c: o[c]['i_drv_ua']), ('wd_oscillater · latch NOR + buf_4 (CLK, 200 fF)', lambda c: o[c]['i_log_ua']),
             ('wd_oscillater (total)', lambda c: o[c]['idd_ua']),
             ('wd_por · divisor R1–R2', lambda c: p[c]['i_div_ua']), ('wd_por · detector RL + MN', lambda c: p[c]['i_det_ua']),
             ('wd_por · inv + and2', lambda c: p[c]['i_log_ua']), ('wd_por (total)', lambda c: p[c]['idd_ua']),
             ('wd_reset_sync (medio a 10 kHz)', lambda c: M['wd_reset_sync'][c]['iavg_na'] * 1e-3),
             ('EN_INPUT (medio a 10 kHz)', lambda c: M['EN_INPUT'][c]['iavg_na'] * 1e-3),
             ('WDI_INPUT (medio a 10 kHz)', lambda c: M['WDI_INPUT'][c]['iavg_na'] * 1e-3)]
    tot = lambda c: o[c]['idd_ua'] + p[c]['idd_ua'] + sum(M[k][c]['iavg_na'] * 1e-3 for k in ('wd_reset_sync', 'EN_INPUT', 'WDI_INPUT'))
    items.append(('Total de los bloques verificados', tot))
    items.append(('Integración medida (osc + POR, régimen)', lambda c: M['integracion'][c]['i_tot_ua']))
    head = [P_('Bloque', 'cellh'), P_('Típico tt · 27 °C · 1,20 V [µA]', 'cellh'), P_('tt: mín … máx [µA]', 'cellh'), P_('ss: mín … máx [µA]', 'cellh'), P_('Peor caso [µA]', 'cellh')]
    rows = [head]; bold = []
    for name, f in items:
        worst = max(f(c) for c in CONDS)
        nd = 4 if worst < 0.01 else 3 if worst < 0.1 else 2
        st = 'cellb' if ('total' in name.lower() or 'Integración' in name) else 'cell'
        if st == 'cellb': bold.append(len(rows))
        rows.append([P_(name, st), P_(num(f(TYP), nd), st), P_(rng(f, 'tt', nd), st), P_(rng(f, 'ss', nd), st), P_(num(worst, nd), st)])
    t = table(rows, [70 * mm, 30 * mm, 28 * mm, 28 * mm, 22 * mm])
    for r in bold: t.setStyle(TableStyle([('BACKGROUND', (0, r), (-1, r), BAND)]))
    return t


# ------------------------------------------------------------------ errores y márgenes
def build_errors():
    o = M['wd_oscillater']; por = O['por']; ig = O['integ']
    rows = [[P_('Magnitud', 'cellh'), P_('tt', 'cellh'), P_('ss', 'cellh'), P_('Lectura', 'cellh')]]
    def R(name, f, nd, unit, txt):
        rows.append([P_(name), P_(f'{rng(f, "tt", nd)} {unit}'), P_(f'{rng(f, "ss", nd)} {unit}'), P_(txt)])
    R('Error de período vs 100 µs', lambda c: o[c]['err_pct'], 2, '%', 'Dentro de ± 2 %; la deriva viene de rhigh/rppd (TC) y del sobrepaso de VC.')
    R('Error de ciclo de trabajo vs 50 %', lambda c: o[c]['duty_pct'] - 50, 2, 'pp', 'Simétrico: VH y VL equidistan de VDD/2.')
    R('Offset de comp_sup', g(A['comp_sup'], 'offset_mv'), 2, 'mV', 'Sin mismatch (corner global); Monte Carlo pendiente.')
    R('Offset de comp_inf', g(A['comp_inf'], 'offset_mv'), 2, 'mV', 'Ídem.')
    R('Sobrepaso de VC sobre VH', g(o, 'ov_h_mv'), 2, 'mV', 'Retardo del comparador × pendiente de VC; aporta al error de período.')
    R('Sobrepaso de VC bajo VL', g(o, 'ov_l_mv'), 2, 'mV', 'Ídem en la descarga.')
    R('Error de copia del espejo de bias', g(M['bias'], 'mirror_err_pct'), 1, '%', 'V_DS distinto en XM1 y XM3 (modulación de canal).')
    R('Margen POR: 1,08 V − VDD de liberación', lambda c: (1.08 - por[c]['va']) * 1e3, 0, 'mV', 'Positivo en todas las condiciones: libera antes de la VDD mínima.')
    R('Margen POR: VDD de liberación − 0,45 V', lambda c: (por[c]['va'] - 0.45) * 1e3, 0, 'mV', 'Lejos del piso donde la lógica deja de ser fiable.')
    R('VDD al liberar POR_B (integración, rampa de 1 ms)', g(ig, 'vBC'), 3, 'V', 'En ss supera 1,08 V en algunas condiciones: POR_B sale con el 2.º flanco de CLK, cuando la rampa ya pasó la VDD mínima.')
    return table(rows, [50 * mm, 28 * mm, 28 * mm, 74 * mm])


# ------------------------------------------------------------------ anexo: tablas por condición
def annex(title, cols, getters, nds, note=None):
    head = [P_('Corner', 'cellh'), P_('T [°C]', 'cellh'), P_('VDD [V]', 'cellh')] + [P_(c.replace('→', '→<br/>'), 'cellh') for c in cols]
    rows = [head]
    for c in CONDS:
        rows.append([P_(c[0]), P_(str(c[1]).replace('-', '−')), P_(num(c[2], 2))] + [P_(num(f(c), nd)) for f, nd in zip(getters, nds)])
    n = len(cols); w_rest = (180 - 36) / n
    t = table(rows, [12 * mm, 12 * mm, 12 * mm] + [w_rest * mm] * n)
    t.setStyle(TableStyle([('LINEBELOW', (0, 9), (-1, 9), 0.8, INK2)]))
    out = [Paragraph(title, S['h3']), t]
    if note: out.append(Paragraph(note, S['note']))
    return KeepTogether(out)


def build_annex():
    o = M['wd_oscillater']; p = M['wd_por']; pr = O['por']
    L = []
    L.append(annex('A.1 · bias', ['I_REF [µA]', 'I_OUT [µA]', 'I_DD [µA]', 'VBN [V]', 'V_SG [V]', 'Error espejo [%]', 't_est [µs]'],
                   [g(M['bias'], k) for k in ('iref_ua', 'iout_ua', 'idd_ua', 'vbn', 'vsg', 'mirror_err_pct', 'tset_us')], [2, 2, 2, 3, 3, 1, 2]))
    L.append(annex('A.2 · schmitt', ['V_T+ [V]', 'V_T− [V]', 'Hist. [mV]', 't_pHL [ps]', 't_pLH [ps]', 't_f [ps]', 't_r [ps]', 'I pico DC [µA]', 'E/ciclo [fJ]'],
                   [g(A['schmitt'], 'vt_plus'), g(A['schmitt'], 'vt_minus'), g(A['schmitt'], 'hyst_mv')] + [g(M['schmitt'], k) for k in ('tphl_ps', 'tplh_ps', 'tf_ps', 'tr_ps', 'ipk_dc_ua', 'e_cycle_fj')],
                   [3, 3, 0, 0, 0, 0, 0, 1, 1]))
    for cell in ('comp_sup', 'comp_inf'):
        L.append(annex(f'A.{3 if cell == "comp_sup" else 4} · {cell}', ['Offset [mV]', 'I_cola [µA]', 'I_DD alto [µA]', 'I_DD bajo [µA]', 't_d OUT↑ [ns]', 't_d OUT↓ [ns]', 't_r [ns]', 't_f [ns]'],
                       [g(A[cell], 'offset_mv'), g(M[cell], 'itail_ua'), g(M[cell], 'idd_outhi_ua'), g(M[cell], 'idd_outlo_ua'), g(M[cell], 'tpd_lh_us', 1e3), g(M[cell], 'tpd_hl_us', 1e3), g(M[cell], 'tr_ps', 1e-3), g(M[cell], 'tf_ps', 1e-3)],
                       [2, 2, 2, 2, 0, 0, 2, 2]))
    L.append(annex('A.5 · wd_oscillater', ['T [µs]', 'Error [%]', 'Duty [%]', '1.er flanco [µs]', 'Sobrep. VH [mV]', 'RST→CLK [ps]', 't_r CLK [ps]', 't_f CLK [ps]', 'I_DD [µA]'],
                   [g(o, k) for k in ('T_us', 'err_pct', 'duty_pct', 'tsu_us', 'ov_h_mv')] + [g(o, 'dly_rst_ps'), g(o, 'clk_tr_ps'), g(o, 'clk_tf_ps'), g(o, 'idd_ua')],
                   [2, 2, 1, 1, 2, 0, 0, 0, 2], note='Retardo RST→CLK, t_r y t_f de CLK: banco aparte del latch NOR + buf_1/buf_4 con las mismas cargas (el paso del oscilador completo no resuelve ps).'))
    L.append(annex('A.6 · wd_oscillater — consumo por bloque [µA]', ['bias', 'comp_inf', 'comp_sup', 'divisor', 'buf_1 → RC', 'latch + buf_4', 'Total'],
                   [g(o, k) for k in ('i_bias_ua', 'i_cinf_ua', 'i_csup_ua', 'i_div_ua', 'i_drv_ua', 'i_log_ua', 'idd_ua')], [2, 2, 2, 2, 2, 4, 2]))
    L.append(annex('A.7 · wd_por', ['V lib. [V]', 'V aserc. [V]', 'V_OK DC [V]', 'Ret. 1 µs [µs]', 'Ret. corte [µs]', 't_lib 10 µs [µs]', 't_r [ns]', 'I_DD [µA]', 'I pico [µA]'],
                   [g(pr, 'va'), g(pr, 'vc'), g(p, 'vok_dc'), g(pr, 'dd'), g(pr, 'de'), g(p, 't_rel_us'), g(p, 'tr_ps', 1e-3), g(pr, 'iua'), g(p, 'ipk_ua')],
                   [3, 3, 3, 2, 2, 2, 2, 2, 1]))
    L.append(annex('A.8 · wd_reset_sync', ['Latencia mín [T]', 'Latencia máx [T]', 'CLK→P1 [ps]', 'CLK→POR_B [ps]', 'Aserción [ps]', 't_r [ps]', 't_f [ps]', 'Fuga [pA]', 'I medio [nA]'],
                   [lambda c: min(lat_rs(c)), lambda c: max(lat_rs(c))] + [g(M['wd_reset_sync'], k) for k in ('t_clk_mid_ps', 't_clk_out_ps', 't_assert_ps', 'out_tr_ps', 'out_tf_ps', 'ileak_pa', 'iavg_na')],
                   [2, 2, 0, 0, 0, 0, 0, 0, 2]))
    for i, (cell, k) in enumerate((('EN_INPUT', 'EN'), ('WDI_INPUT', 'WDI'))):
        L.append(annex(f'A.{9 + i} · {cell}', ['Lat. mín [T]', 'Lat. máx [T]', 'CLK→SYNC [ps]', 'CLK→EDGE↑ [ps]', 'CLK→EDGE↓ [ps]', 't_r [ps]', 't_f [ps]', 'Fuga [pA]', 'I medio [nA]'],
                       [lambda c, k=k: min(O[k][c]['lat_T']), lambda c, k=k: max(O[k][c]['lat_T'])] + [g(M[cell], kk) for kk in ('t_clk_mid_ps', 't_clk_out_ps', 't_clk_outfall_ps', 'out_tr_ps', 'out_tf_ps', 'ileak_pa', 'iavg_na')],
                       [2, 2, 0, 0, 0, 0, 0, 0, 2]))
    L.append(annex('A.11 · Integración', ['VDD lib. POR_RAW_N [V]', 'VDD lib. POR_B [V]', 'Latencia A [T]', 't POR_B (A) [µs]', 'I total [µA]', 'I osc [µA]', 'I POR [µA]'],
                   [g(O['integ'], 'vRC'), g(O['integ'], 'vBC'), g(O['integ'], 'nTA'), g(M['integracion'], 't_porb_A_us'), g(M['integracion'], 'i_tot_ua'), g(M['integracion'], 'i_osc_ua'), g(M['integracion'], 'i_por_ua')],
                   [3, 3, 2, 0, 2, 2, 2]))
    return L


# ------------------------------------------------------------------ documento
def on_page(cv, doc):
    cv.saveState(); cv.setFont('DV', 7); cv.setFillColor(INK2)
    cv.drawString(15 * mm, 10 * mm, 'Watchdog IHP SG13G2 · Resumen de validación tt/ss')
    cv.drawRightString(195 * mm, 10 * mm, f'pág. {doc.page}')
    cv.setStrokeColor(LINE); cv.setLineWidth(0.4); cv.line(15 * mm, 13 * mm, 195 * mm, 13 * mm)
    cv.restoreState()


def main():
    doc = BaseDocTemplate(OUTPDF, pagesize=A4, leftMargin=15 * mm, rightMargin=15 * mm, topMargin=14 * mm, bottomMargin=18 * mm,
                          title='Watchdog IHP SG13G2 — Resumen de validación tt/ss', author='Diego M. (con Claude)', subject='Valores clave por celda')
    fr = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='f')
    doc.addPageTemplates([PageTemplate(id='p', frames=[fr], onPage=on_page)])
    E = []
    E.append(Paragraph('Watchdog IHP SG13G2 — Resumen de validación tt/ss', S['h1']))
    E.append(Paragraph(f'Repositorio die-mirarchi/Watchdog-IHP-SG13G2, esquemáticos del commit 96250e1 · {datetime.date(2026, 11, 6).strftime("%d/%m/%Y")} · '
                       'ngspice 42 + PSP103 (OSDI) · mos_tt y mos_ss, res_typ, cap_typ · T = −40, 27, 85 °C · VDD = 1,08, 1,20, 1,32 V (18 condiciones por celda).', S['sub']))
    E.append(Paragraph('Las 180 corridas de validación funcional pasaron (18/18 por celda). Esta segunda tanda agrega corrientes por bloque, retardos y tiempos de transición. '
                       'Los consumos de cada celda se midieron con la celda en una fuente propia; los bloques internos del oscilador y del POR, con amperímetros (fuentes de 0 V) '
                       'en su alimentación. Los flancos se midieron con puntos de simulación densos (20–50 ps) alrededor de cada transición. '
                       'Los gráficos están en <b>graphs/&lt;celda&gt;/&lt;corner&gt;/</b>.', S['p']))
    E.append(Paragraph('Convenciones: «típico» = tt, 27 °C, 1,20 V; los rangos cubren las 9 combinaciones de T y VDD de cada corner; «a / b» indica dos magnitudes en la misma fila. '
                       'Criterios: los usados en los testbenches de validación (o la especificación de la celda cuando existe).', S['note']))
    E.append(Paragraph('1 · Valores clave por celda', S['h2']))
    E.append(build_summary())
    E.append(CondPageBreak(90 * mm))
    E.append(Paragraph('2 · Presupuesto de consumo', S['h2']))
    E.append(Paragraph('Corriente media de la fuente en régimen. Los bloques digitales se miden a 10 kHz (frecuencia de CLK); su consumo es dinámico y escala con la frecuencia.', S['p']))
    E.append(build_power())
    if os.path.exists(f'{MET}/consumo.png'):
        E.append(Spacer(1, 6)); E.append(Image(f'{MET}/consumo.png', width=180 * mm, height=180 * mm * 0.42))
    E.append(KeepTogether([Paragraph('3 · Errores y márgenes', S['h2']), build_errors(), Paragraph('Limitaciones: corners globales de MOS (tt, ss) con resistencias y capacitores típicos; sin mismatch local (los offsets reales serán mayores: falta Monte Carlo); '
                       'sin parásitos de layout. En la integración, los FF del sincronizador se modelan en XSPICE (el FF real se valida aparte en wd_reset_sync). '
                       'Precisión temporal del oscilador completo: el período cambia 0,1–0,4 % según el paso de simulación.', S['note'])]))
    E.append(PageBreak())
    E.append(Paragraph('Anexo A · Resultados por condición', S['h2']))
    E.append(Paragraph('Una fila por condición; la línea gruesa separa tt (arriba) de ss (abajo).', S['note']))
    E += build_annex()
    doc.build(E)
    print('PDF', OUTPDF)


if __name__ == '__main__':
    main()
