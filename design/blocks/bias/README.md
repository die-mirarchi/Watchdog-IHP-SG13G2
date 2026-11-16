# bias — polarización de los comparadores (versión 1.0)

Referencia resistiva simple: R1 (rhigh 0,5/237 µm) fija I<sub>ref</sub> ≈ 1,2 µA en el diodo
XM1 (2/4, VBN); XM3 (2/4) la copia al diodo PMOS XM2 (4/4, VBP). Sin punto de
operación degenerado, no necesita arranque. C1 (VBN–VSS) y C2 (VDD–VBP):
cap_cmim 26×26 µm.

Verificación: arranque sin punto degenerado 18/18 (tt, ss × 3 T × 3 VDD);
VBN = 0,302–0,382 V; I<sub>DD</sub> 1,81–3,44 µA.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
