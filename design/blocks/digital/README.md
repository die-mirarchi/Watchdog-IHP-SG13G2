# wd_digital v3 — contador y control (revisión 5 del documento de diseño, 9/11/2026)

Versión vigente: **v3** (`*_v3.*`). Los archivos `*_v2.*` quedan como historia.

## Comportamiento
- **Activo desde el POR**, sin intervención del microcontrolador. No hay pin EN.
- **Modo arranque** tras el POR y tras cada pulso: timeout de 102 401 T = 10,00 s hasta el primer WDI.
- **Modo normal** (desde el primer WDI), timeout según los pines SET1 SET0, latcheados mientras POR_B = 0:

| SET1 SET0 | Timeout | Toma |
|---|---|---|
| 00 / sin conectar (pull-down) | 10 241 T = 1,000 s | Q13·Q11 |
| 01 | 1025 T = 100,1 ms | Q10 |
| 10 | 102 401 T = 10,00 s | Q16·Q15·Q12 |
| 11 | deshabilitado | — |

- Pulso de RESET: 1025 T = 100,1 ms (termina con Q10); WDI se ignora durante el pulso.
- T = 97,656 µs (RT del oscilador con L = 170,7 µm).

## Ecuaciones (= compuertas)
```
wd_bit:  D = nor2(xnor2(Q,CI), CLR)   CO = and2(Q,CI)   CI0 = tiehi      (17 bits)
tomas:   T1 = and2(Q13,Q11)   T10 = and3(Q16,Q15,Q12)   T01 = Q10
ctrl:    CFGi = dllrq_1(D=SETi, GATE_N=POR_B, RESET_B=HI)
         DIS  = and2(CFG0,CFG1)          ACTIVE = nor2(DIS, RESET)
         TON  = mux4(T1, T01, T10, LO; S0=CFG0, S1=CFG1)
         TO   = mux2(A0=T10, A1=TON, S=NB)                 ; arranque -> 10 s
         HIT  = and3(ACTIVE, TO, ~WDI_EDGE)
         RS+  = a21o(RESET, Q10_N, HIT)
         NB+  = and2(a21o(WDI_EDGE, ACTIVE, NB), RS_N)       ; BOOT = NB_N
         CLR  = mux2(A0=or3(DIS, WDI_EDGE, HIT), A1=Q10, S=RESET)
```
86 celdas sg13g2 tamaño 1 (19 FF + 2 latches), 1142 transistores.

## Pines del símbolo
`CLK POR_B SET0 SET1 WDI_EDGE RESET ACTIVE BOOT` (ACTIVE y BOOT: observación).
Los pads SET0/SET1 son `sg13g2_IOPadIn` con pull-down rhigh ≈ 1 MΩ (W 0,5 / L ≈ 338 µm) del pad a IOVSS.

## Verificación
- `verilog/`: Icarus con los modelos de IHP (`PDK_ROOT=... sh run_icarus_v3.sh`): 36/36 chequeos con las constantes reales, 4 × 250 000 ciclos aleatorios idénticos a `model3.py`, 9/9 mutantes detectados (`mutantes3.log`).
- `schematic/simulation/tb_wd_digital_v3_esc.spice`: nivel transistor, netlist idéntico salvo las tomas (DONE = T01 = Q1, T1 = Q3·Q2, T10 = Q5·Q4·Q2). Resultados en `resultados_v3_tt.log` y `resultados_v3_ss.log`.
