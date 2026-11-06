# Barrido tt/ss de todas las celdas (6/11/2026)

Scripts que generan `graphs/` y las tablas de la sección 9 del documento de diseño.
Corren en el contenedor de Claude (ngspice 42 + OSDI compilado con OpenVAF-Reloaded,
PDK clonado). Para usarlos en otra máquina, ajustar las rutas de `common.py`
(`PDK`, `REPO`, `VAL`) y el rcfile de xschem.

1. Netlist de cada celda: `xschem -n -s -q -x -r --rcfile <xschemrc> -o net -N <celda>.spice <celda>.sch`
   (`common.cellnet()` lo convierte en `.subckt` con los pines del símbolo + VDD VSS).
2. `python3 c_analog.py`  → bias, schmitt, comp_sup, comp_inf
3. `python3 c_osc.py`     → wd_oscillater (reintento con tmax 0,07/0,13 µs)
4. `python3 c_por.py`     → wd_por (plantilla `tb_wd_por_template.spice`)
5. `python3 c_rsync.py`   → wd_reset_sync (`gen_reset_sync.py`, fuente VBK)
6. `python3 c_inputs.py`  → EN_INPUT y WDI_INPUT (VBK en flancos de CLK y de entrada)
7. `python3 c_integ.py`   → integración (FF en XSPICE: `dig.sp`; reintentos de tmax)

Esquinas: mos_tt y mos_ss × (−40, 27, 85 °C) × (1,08, 1,2, 1,32 V), R/C típicos.
Gráficos: color = temperatura, trazo = VDD (`plot.py`).
