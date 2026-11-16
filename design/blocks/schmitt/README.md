# schmitt — inversor Schmitt de 6 transistores (versión 1.0)

La librería sg13g2 no tiene Schmitt. Pila p 1,04/0,13 ×2, pila n 0,76/0,13 ×2,
realimentación p/n 0,42/0,13 sobre P_MID/N_MID. Histéresis 208–310 mV
(V<sub>T+</sub> 0,660–0,824 V, V<sub>T−</sub> 0,414–0,557 V), 18/18 (tt, ss).

Se usa en `comp_sup`, `comp_inf`, `wd_por` y `wd_clkmon`.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
