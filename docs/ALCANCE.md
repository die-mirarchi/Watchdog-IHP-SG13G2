# Alcance inicial de la tesis

Contexto extraído del INFORME.html facilitado por el autor (5 de octubre de 2026).
Se usa como referencia temática; sus implementaciones y resultados no se importan.

- Watchdog para microcontrolador, tecnología IHP SG13G2.
- Habilitación EN y entrada de servicio WDI.
- Objetivos preliminares: timeout de 1 s y reset activo bajo de 100 ms.
- Luego del reset, esperar un nuevo flanco de EN.
- Referencia inicial de alimentaciones: núcleo 1,2 V e interfaces 3,3 V.
- El informe menciona ±20 % en PVT como objetivo aún no garantizado.

Estos puntos deben convertirse en requisitos revisados antes de diseñar.
La organización por bloques no obliga a reutilizar la arquitectura anterior.
No hay esquemáticos, símbolos, layouts, RTL, netlists de diseño ni resultados
del watchdog en la versión inicial limpia. No existe validación del circuito.

La prueba de instalación usa un solo transistor del PDK en `build/`, generado
al ejecutar el diagnóstico. Comprueba modelos y herramientas, no la tesis.

## Estado en la versión 1.0 (16/11/2026)

El diseño de esquemáticos está completo y se da por funcional y validado en
simulación de esquemático; la etapa siguiente es el layout. Frente a los
objetivos preliminares de arriba:

- **EN eliminado** (revisión 5): el watchdog vigila desde el POR, con modo
  arranque de 10 s hasta el primer WDI. Tras un reset vuelve solo al modo
  arranque; no espera un flanco de EN.
- **Timeout** configurable por `SET1 SET0`: 0,1 / 1 / 10 s, o deshabilitado (11).
- **Pulso de reset** de 100 ms. En el top v1.0 `RESET_OUT` es activo en alto y
  sin pad; la salida de drenador abierto activa baja queda para el anillo de pads.
- **Alimentación**: núcleo 1,2 V ±10 %. Las interfaces de 3,3 V (pads) quedan
  pendientes.
- **Precisión de tiempos**: −0,7…+1,4 % en MOS × T × VDD con R/C típicos, pero
  −21…+24 % con las esquinas de proceso de R<sub>T</sub> y C<sub>T</sub>: el ±20 % solo se
  garantiza con trim o con una especificación que admita ese rango.
- **Agregados**: reset de encendido propio, liberación síncrona del reset
  (34 flancos), configuración autorreparable y detector de pérdida de reloj
  que reinicia el watchdog.

Resumen y bloques en el [README](../README.md).
