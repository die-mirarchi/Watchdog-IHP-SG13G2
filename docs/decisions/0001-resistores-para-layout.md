# 0001 · Resistores para layout (F0)

Fecha: 25/11/2026 · Estado: propuesta, simulada a nivel de esquemático · Base: v1.0 (commit 6188259), PDK 5e6d592.

## Problema

Varios resistores de la v1.0 no se pueden dibujar tal cual: son barras rectas de hasta 675 µm (`b=0`), y RT es un
meandro de 16 tramos de 661 µm (≈ 19 × 661 µm). Plegarlos cambia los parámetros que LVS compara, y si se hace sin
cuidado cambia R.

## Cómo tratan los resistores el modelo y LVS (leído del PDK)

- **Modelo** (`resistors_mod.lib`, rhigh y rppd): `leff = (b+1)·l + (2/1,85·weff + ps)·b`. Con el mismo `leff` y `w`,
  R, la capacitancia distribuida y el TC son idénticos. Cada tramo en serie agrega 2·rz (rhigh 80 Ω·µm/w, rppd 35 Ω·µm/w).
- **LVS** (KLayout): extrae `w`, `l`, `ps`, `b`, `m` de cada resistor y los compara **exactos**.
  - Resistores en serie con igual `w`, `ps`, `b`, `m` se **suman en `l`** (opción por defecto). Unidades rectas
    (`b=0`) cuyas longitudes suman la `l` del esquemático pasan LVS **sin tocar el esquemático**.
  - El `lvs_format` de los símbolos xschem `rppd`/`rhigh` **no escribe `ps`**. Con `b>0` el layout da `ps = 0,18 µm`
    y el esquemático `ps = 0` → LVS falla. Afecta ya a RT en la v1.0 (`b=15`).
  - Dummies con todos sus terminales a un mismo nodo: se eliminan con `--purge_devices`.
  - Taps (ntap1/ptap1) se extraen como dispositivos por defecto: usar `--disable_tap_extraction` o dibujarlos en el esquemático.
  - MOS: compara W·m y L; los dedos en paralelo se suman (centroide común sin cambiar el esquemático). MIM iguales en
    paralelo se suman en `m` (CT 4 × 64×64 OK).

Verificación de lo anterior: lectura del deck + réplica de la comparación con la API de KLayout 0.30.5
(`ps` 0,18 vs 0 → falla; 10 × 45 µm en serie → 1 × 450 µm → pasa). **Falta correrlo con el deck real** (PROBAR).

## Decisión

| Resistor | v1.0 | Layout | ¿Cambia el esquemático? |
|---|---|---|---|
| RT (rppd, osc.) | w 1, l 661, b 15 | PCell w 1, **l 104,70, b 99** (≈ 118 × 105 µm, debajo de CT) | Sí: `l`, `b`; `ps=0.18u` en el netlist LVS |
| R1–R3 (rhigh, divisor osc.) | 3 × w 1, l 450 | 3 × 10 unidades de 45 µm, intercaladas, con dummies | No |
| R1 POR | w 0,5, l 320 | 10 × 32 µm | No |
| R2 POR | w 0,5, l 385 | 11 × 35 µm | No |
| R4 POR (RL) | w 0,5, l 675 | 27 × 25 µm | No |
| R3 POR | w 0,5, l 65 | sin cambio (barra recta) | No |
| R1 bias | w 0,5, l 237 | 8 × 29,625 µm | No |

`l` de RT: `(leff_v1 − 99·(2/1,85 + 0,18))/100` con `leff_v1 = 16·661 + 15·1,2611 = 10 594,92 µm` → 104,70 µm (grilla 5 nm, error −6 ppm).

## Resultados (ngspice 42, PSP103/R3_CMC por OSDI)

Resistencia (tt, 27 °C): RT 2738,32 → 2738,30 kΩ; RT replegado sin corregir `l` (l = 105,76) → 2765,70 kΩ (**+1,0 %**).
Unidades: +0,23 % (divisor osc., los tres iguales → relación exacta), +0,30 % / +0,31 % (R1/R2 POR → k −0,01 %),
+0,33 % (RL), +0,32 % (bias).

| Prueba | v1.0 | Propuesta | Diferencia |
|---|---|---|---|
| T osc., 45 esquinas MOS×T×VDD (R/C típ.) | 96,92–98,95 µs | 96,88–99,01 µs | −0,20…+0,33 %, media +0,004 % |
| T osc., R/C wcs / bcs (tt, 3 T) | hasta 122,81 / desde 76,68 µs | 122,78 / 76,69 µs | igual |
| T osc., control RT sin corregir `l` | — | — | **+0,85…+1,08 %** (detectado) |
| POR, 45 esquinas MOS×T×R/C | sube 0,492–1,017 V, baja 0,389–0,813 V | 0,491–1,014 V / 0,388–0,811 V | −2,9…0 mV · PASS |

Ruido numérico de T (artefacto del latch, misma esquina con tmax 0,05–0,13 µs): ±0,2–0,35 %. Las diferencias de la
propuesta están dentro de ese ruido; la del control no.

Reproducir: `verification/layout_prep/f0_resistores.py` (desde `design/top/schematic/simulation/`).

## Pendiente

- Correr DRC/LVS real con un RT de prueba (PCell b=99) y una cadena de unidades: confirmar `ps` y la suma en serie.
- Confirmar en DRC que RT puede ir debajo de CT (placa inferior de CT en Metal5 a VSS).
- Después del layout: extracción de parásitos (acople RT–placa de CT, cables de las unidades) y re-simular T.
