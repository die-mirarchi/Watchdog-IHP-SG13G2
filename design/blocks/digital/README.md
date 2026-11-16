# wd_digital — núcleo digital (versión 1.0)

`wd_digital` = `wd_control` (x1) + `counter17` (x2) + `sg13g2_tiehi` (x3, HI).
Pines: `CLK POR_B SET1 SET0 WDI_EDGE RESET BOOT ACTIVE`.

## Comportamiento
- Activo desde el POR; **modo arranque** (timeout 102 400·T = 10 s) tras el POR,
  tras cada pulso de reset y tras una pérdida de reloj, hasta el primer WDI.
- **Modo normal**: timeout por SET1 SET0 = 00 → 1 s (T00), 01 → 0,1 s (T01),
  10 → 10 s (T10), 11 → deshabilitado.
- **Pulso de RESET** de 1025·T = 100 ms (termina con Q10); WDI se ignora.
- **Configuración autorreparable**: los latches CFG releen SET1/SET0 en el POR
  y en cada pulso de RESET; DIS exige 11 en los latches y en los pines.

## Ecuaciones de wd_control
```
GN    = and2(POR_B, RS_N)                       ; x18
CFGi  = dllrq_1(D = SETi, GATE_N = GN, RESET_B = HI)
DIS   = and4(CFG0, SET0, SET1, CFG1)            ; x4
ACTIVE= nor2(DIS, RESET)                        ; x14
TON   = mux4(T00, T01, T10, T10; S0 = CFG0, S1 = CFG1)
TO    = mux2(A0 = T10, A1 = TON, S = NB)        ; arranque -> 10 s
HIT   = and3(ACTIVE, TO, ~WDI_EDGE)
RESET+= a21o(RESET, Q10_N, HIT)                 ; x16 dfrbp_2 -> RESET_OUT del top
NB+   = and2(a21o(WDI_EDGE, ACTIVE, NB), RS_N)  ; BOOT = ~NB
CLR   = buf_2(mux2(A0 = or3(DIS, WDI_EDGE, HIT), A1 = T01, S = RESET))
```
wd_control: 17 celdas, 222 MOS. Núcleo completo: 105 celdas (19 FF + 2 latches), 1226 MOS.

## Verificación
- Lógica del top (Icarus, `design/top/schematic/simulation/run_logic.sh`):
  38/38 chequeos y 5 654 058 ciclos sin diferencias contra el modelo.
- `upset_tb.v`: error forzado en los latches CFG, casos A y B: PASS.
- ngspice tt/ss 9/9 con contador escalado (`wd_control_tb.sch`).
