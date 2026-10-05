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
