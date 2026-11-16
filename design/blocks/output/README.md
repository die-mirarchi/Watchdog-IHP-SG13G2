# Salida de reset y pads — pendiente (fuera de la versión 1.0)

El top `wd_watchdog` v1.0 no incluye pads: `RESET_OUT` es una salida lógica
activa en alto. Para el chip queda pendiente:

- Salida de drenador abierto activa baja con `sg13g2_IOPadTriOut4mA`
  (c2p = LO, c2p_en = RESET_OUT); R<sub>on</sub> medido 217 Ω.
- `sg13g2_IOPadIn` para SET1, SET0 y WDI, con pull-down rhigh ≈ 1 MΩ
  (0,5/338 µm) en SET.
- Verificar la secuencia IOVDD presente con VDD = 0.
