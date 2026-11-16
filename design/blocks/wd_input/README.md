# WDI_INPUT — sincronizador y detector de flanco (versión 1.0)

x1, x2 (dfrbpq_1) sincronizan `WDI_IN` con CLK; x3 (dfrbp_1) guarda el valor
anterior; `WDI_EDGE = WDI_SYNC · HIST_N` (x4, and2_1) dura un período por cada
flanco ascendente. Reset por `POR_B`. Latencia 1–2·T; un nivel debe durar
≥ 0,25 ms para detectarse (se especifica 1 ms). En el top v1.0 no hay pad.

Verificación: 18/18 (tt, ss); lógica del top 38/38.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
