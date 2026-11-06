# Gráficos de validación — mos_tt y mos_ss

Generados el 6/11/2026 a partir del netlist de Xschem del repositorio (commit 96250e1).
Cada gráfico superpone las 9 condiciones: **color = temperatura** (azul −40 °C, verde 27 °C, naranja 85 °C) y **trazo = VDD** (rayado 1,08 V, continuo 1,2 V, punteado 1,32 V). R/C típicos.
Simulador: ngspice 42 + OSDI (PSP103, r3_cmc), `.option method=gear maxord=2 reltol=1e-3`.

Estructura: `graphs/<celda>/<tt|ss>/*.png`. Scripts: `verification/testbenches/pvt_tt_ss/`.

| Celda | Prueba | Criterio | tt | ss | Resultado clave | Archivos |
|---|---|---|---|---|---|---|
| bias | Rampa de VDD 10 µs | VBN 0,3–0,7 V; I_DD 1–4 µA; sin deriva final | 9/9 | 9/9 | VBN 0,302–0,382 V, I_DD 1,81–3,44 µA | bias_<c>_arranque.png |
| schmitt | DC subida/bajada | histéresis > 100 mV, rail a rail | 9/9 | 9/9 | histéresis 208–310 mV | schmitt_<c>_histeresis.png |
| comp_sup | DC de VP alrededor de 2/3·VDD (con bias real) | offset < 10 mV en módulo | 9/9 | 9/9 | offset −2,5…−0,2 mV | comp_sup_<c>_umbral.png |
| comp_inf | DC de VN alrededor de VDD/3 (con bias real) | offset < 10 mV en módulo | 9/9 | 9/9 | offset −0,10…−0,05 mV | comp_inf_<c>_umbral.png |
| wd_oscillater | Rampa 10 µs + 0,7 ms, CLK con 200 fF | T 100 µs ±20 %; duty 45–55 %; T(CLK)=T(VC) ±1 % | 9/9 | 9/9 | T 99,40–101,50 µs, I_DD 6,3–11,8 µA | osc_<c>_formas_de_onda.png, osc_<c>_resumen.png |
| wd_por | tb_wd_por_v2 (14 ms) | liberación 0,45–1,03 V; caída reactiva; RC; corte; I_DD ≤ 2 µA | 9/9 | 9/9 | umbral 0,728–0,897 V, I_DD 0,83–1,36 µA | por_<c>_umbral_rampa_lenta.png, por_<c>_rampa_rapida_y_corte.png, por_<c>_resumen.png |
| wd_reset_sync | 8 fases de liberación, reloj buf_4 + VBK | POR_B en el 2.º flanco; P1 en el 1.º; aserción ≤ 100 ns | 9/9 | 9/9 | latencia 1,0–2,0 T; aserción 1,1–1,5 ns | rsync_<c>_liberacion.png, rsync_<c>_retardos.png |
| EN_INPUT | 3 pulsos (fases distintas) + 1 pulso corto | 3 EDGE de 1 T alineados con CLK; latencia 1–2 T | 9/9 | 9/9 | latencia 1,70 / 1,00 / 2,00 T | EN_INPUT_<c>_deteccion.png |
| WDI_INPUT | ídem | ídem | 9/9 | 9/9 | latencia 1,70 / 1,00 / 2,00 T | WDI_INPUT_<c>_deteccion.png |
| integracion | osc + POR + sync (FF XSPICE), 2,1 ms | POR_B en el 2.º flanco tras POR_RAW_N en las 3 ventanas; la caída baja POR_B | 9/9 | 9/9 | VDD al liberar POR_B (rampa lenta) 0,84–1,15 V | integracion_<c>.png |

Notas numéricas:

- Oscilador: 4 de 18 corridas necesitaron tmax 0,07 µs (artefacto del latch: un pulso espurio que cambia de lugar con el paso).
- wd_reset_sync, EN_INPUT, WDI_INPUT: fuente auxiliar `VBK` (sin efecto eléctrico) con puntos de quiebre cada 25 ps alrededor de los flancos; sin ella los FF capturan en el flanco de bajada.
- Integración: FF del sincronizador en XSPICE (`d_dff`), `gmin=1e-11`, reintentos de tmax 100 → 70 → 130 ns (6 de 18 corridas).
