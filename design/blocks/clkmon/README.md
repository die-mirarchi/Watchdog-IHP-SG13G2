# wd_clkmon — detector de pérdida de reloj (versión 1.0)

Referencia propia (independiente del oscilador): MN0[29:0] = 30 × NMOS 0,15/10 en
serie con compuerta a VDD sobre el diodo MP0 (0,5/2). MP1[3:0] y MP2[3:0] (pilas
de 4 × 0,15/10, ≡ 0,15/40; relación 1/67) cargan CA y CB (MIM 28×28, 1,18 pF);
MN1/MN2 (0,5/0,13) los descargan en cada fase de CLK (CLKP/CLKN por dos inv_1).
Si CLK se detiene en 0 o en 1, un integrador cruza V<sub>T+</sub> del Schmitt y
`CLK_LOST = ¬(SA·SB)` = 1; el primer flanco lo libera.

En el top, `CLK_LOST` solo reinicia el watchdog (`POR_RAW_N = POR_DET_N·¬CLK_LOST`);
no activa `RESET_OUT`. Todos los MOS con L ≤ 10 µm.

Verificación (`design/top/schematic/simulation/wd_clkmon_pvt.py`): 34/34 en
5 MOS × −40/27/85 °C × 1,08/1,32 V + 4 esquinas de MIM, CLK de 123 µs:
detección 230–2023 µs, V<sub>A</sub>/V<sub>B</sub> con reloj 21–217 mV, 47–189 nA.
Integración en el top (Icarus, `wd_watchdog_clkmon_tb.v`): PASS.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
