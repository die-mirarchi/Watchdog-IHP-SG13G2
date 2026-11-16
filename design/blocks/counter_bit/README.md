# counter17 y one_bit — contador síncrono (versión 1.0)

- `one_bit`: `Q⁺ = (Q ⊕ CI) · ¬CLR`, `CO = CI · Q`; reset asíncrono por POR_B.
- `counter17`: 17 `one_bit` con acarreo en cadena (CI del bit 0 = HI) y tomas
  `T01 = Q10` (1024·T = 100 ms), `T00 = Q11·Q13` (10 240·T = 1 s),
  `T10 = Q12·Q15·Q16` (102 400·T = 10 s) y `Q10_N`. 87 celdas, 1000 MOS.

`one_bit` también forma el contador de 5 bits de `wd_reset_sync`.
Verificación: Icarus, 131 077 cuentas contra un contador de referencia;
ngspice tt 9/9 y ss 9/9.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
