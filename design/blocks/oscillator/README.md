# wd_oscillater — oscilador de relajación de 10,24 kHz (versión 1.0)

Oscilador RC ratiométrico sin entrada de reset: arranca solo con VDD.
C<sub>T</sub> se carga y descarga por R<sub>T</sub> desde DRIVE; `comp_sup` (V<sub>C</sub> > V<sub>H</sub> → RST) y
`comp_inf` (V<sub>C</sub> < V<sub>L</sub> → SET) gobiernan un latch NOR. V<sub>H</sub> = ⅔·VDD y V<sub>L</sub> = ⅓·VDD salen de
un divisor de tres rhigh iguales, así que T = 2·R<sub>T</sub>·C<sub>T</sub>·ln 2 no depende de VDD.

| Inst. | Valor |
|---|---|
| R4 (R<sub>T</sub>) | rppd W 1 / L 661 µm, b = 15 → 2,738 MΩ |
| C4 (C<sub>T</sub>) | cap_cmim 64×64 µm, m = 4 → 24,62 pF |
| R1–R3 | rhigh W 1 / L 450 µm → 637,7 kΩ c/u |
| C1, C3 | cap_cmim 20×20 µm (filtro de kickback) |
| x1 / x2 / x3 | `bias` / `comp_inf` / `comp_sup` |
| x4, x5 / x6 / x7 | nor2_1 (latch) / buf_1 (DRIVE) / buf_4 (CLK) |

Verificación: 45/45 en 5 MOS × −40/27/85 °C × 1,08/1,2/1,32 V con R/C típicos;
T = 96,95–99,0 µs (nominal 97,90 µs); esquinas de R/C −21,0…+24,3 % (tt).
Consumo 7,71 µA (tt, 27 °C, 1,2 V); 5,33–10,53 µA en PVT.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
