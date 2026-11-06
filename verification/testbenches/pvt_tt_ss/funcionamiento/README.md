# Funcionamiento general: corrientes, tiempo y flancos (6/11/2026)

Segunda tanda de simulaciones sobre los mismos netlists que `../` (mos_tt y mos_ss ×
−40/27/85 °C × 1,08/1,2/1,32 V, R/C típicos). Generan los gráficos de la sección 2 de
`graphs/README.md` y el PDF `verification/Resumen_validacion_tt_ss.pdf`.

Requiere haber corrido antes los scripts de `../` (usa `res_analog.json`, `res_por.json`,
`res_integ.json` y los netlists de `net/`). Rutas: las de `../common.py` (`VAL`, `PDK`, `REPO`).
Salidas: `VAL/out_func/` (netlists, logs, datos), `VAL/met/` (métricas JSON), `VAL/graphs/`.

| Script | Celda | Técnica |
|---|---|---|
| `n_bias.py` | bias | escalón de VDD + `dc VDD` + `dc TEMP`; corrientes por `@n.xb.xm1.nsg13_lv_nmos[ids]` |
| `n_schmitt.py` | schmitt | rampa triangular, escalón de 50 ps (paso máx. 2 ps), `dc` en ambos sentidos |
| `n_comp.py` | comp_sup, comp_inf | bias en fuente aparte; escalones de ±20 mV centrados en el disparo medido; 2.ª pasada con `VBK` (20 ps) en los flancos de OUT |
| `n_osc.py` | wd_oscillater | amperímetros por bloque (`nf.amm`); reintentos de tmax; flancos de CLK en banco aparte (latch NOR + buffers con las mismas cargas) |
| `n_por.py` | wd_por | amperímetros por rama; rampas de 10 µs; `dc VDD`; 2.ª pasada con `VBK` en la liberación |
| `n_dig.py` | wd_reset_sync, EN_INPUT, WDI_INPUT | DUT en fuente propia, reloj con buf_4 en otra fuente; `VBK` cada 25 ps en los flancos |
| `n_integ.py` | integración | amperímetros en osc y POR; FF del sincronizador en XSPICE (`../dig.sp`) |
| `fig_consumo.py`, `build_pdf.py` | — | figura de presupuesto de consumo y PDF de tablas (reportlab, fuentes DejaVu) |

Orden: `n_bias → n_schmitt → n_comp → n_osc → n_por → n_dig → n_integ → fig_consumo → build_pdf`.
Cada script acepta `replot` (salvo bias/schmitt/por/integ, que corren en < 1 min) para regenerar gráficos sin simular.

Notas numéricas:

- El paso de simulación del oscilador completo (0,1 µs) no resuelve flancos de ps: con una 2.ª pasada
  con puntos densos los flancos se corren 0,1–1,2 µs (el período cambia ~0,1–0,4 % con el paso), así que
  t_r/t_f de CLK y el retardo del latch se miden en un banco aparte.
- La salida del POR sigue a VDD mientras la rampa sube: su t_r se mide sobre POR_RAW_N/VDD.
