# wd_por y wd_reset_sync — encendido y liberación del reset (versión 1.0)

## wd_por
Detector de nivel con carga resistiva: divisor R1/R2 (rhigh 0,5/320 y 0,5/385 µm,
k = 0,546) a la compuerta de XM1 (0,3/9,9); carga R4 rhigh 0,5/675 µm (2 MΩ);
Schmitt → VOK; buf_1 → VOKB; RC R3 (rhigh 0,5/65) / C1 (MIM 64×64) para el
retardo; XM3 (p 2/0,13) descarga DELAY al caer VDD; `POR_RAW_N = VOK·DELAY`
(en el top se llama POR_DET_N).

Umbral de subida 0,49–1,02 V, de bajada 0,39–0,81 V (45 esquinas MOS × T × R/C);
independiente de la pendiente de la rampa; ≈ 1,1 µA.

## wd_reset_sync (v2)
Aserción asíncrona y liberación síncrona: x1/x2 (dfrbp, D = VDD) sincronizan,
un contador de 5 `one_bit` habilitado con SYNC·DONE_N cuenta 32 ciclos y x10
pone `POR_B` = 1 en el flanco 34 de CLK (≈ 3,3 ms), retenido por la OR x9.
`POR_RAW_N` = 0 (VDD bajo o pérdida de reloj) reinicia todo.
Verificación: 18/18 a nivel transistor junto con `wd_por`.

## Carpetas

- `schematic/`: esquemáticos y símbolos Xschem (versión 1.0).
- `layout/`: layout (siguiente etapa).
- `char/`: caracterización.
