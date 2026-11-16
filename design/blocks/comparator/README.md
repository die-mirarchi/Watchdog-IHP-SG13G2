# comp_sup / comp_inf — comparadores de dos etapas (versión 1.0)

- `comp_sup`: par NMOS 20/2 (ng = 4), carga PMOS 2/4, segunda etapa XM1 4/4 con
  fuente XM7 2/4 (misma densidad de corriente que la carga: cancela el offset
  sistemático). Salida por `schmitt` (RST). Offset −2,5…−0,2 mV (18/18).
- `comp_inf`: par PMOS 20/1 (ng = 4), carga NMOS 1/8, segunda etapa XM3 2/8 con
  fuente XM2 4/4. Salida por `schmitt` (SET). Offset −0,10…−0,05 mV (18/18).

Colas y fuentes copian VBN / VBP de `bias` (espejos 1:1, mismo W y L).

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
