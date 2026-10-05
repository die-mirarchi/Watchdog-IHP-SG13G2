# Origen y versiones

Base: https://github.com/Fundacion-Fulgor/EAMTA2026-VLSI
Commit de partida: `3d20771853ef9864352e6ba6aa8a691b461cf341`.
Se conserva su historial Git y licencia MIT. La rama principal se adapta como
repositorio independiente para la tesis. El fork previo del curso no se modifica.
Los archivos antiguos del curso permanecen accesibles sólo en el historial.

Se conserva la elección de herramientas del curso y se sustituye su instalador
global por un lanzador Podman local al proyecto, con imagen inmutable. No cambia
`.bashrc`, no crea claves SSH, no modifica contenedores Distrobox existentes.

Herramientas: https://github.com/iic-jku/IIC-OSIC-TOOLS
Imagen y revisión del PDK: `tools-config/toolchain.lock`.
PDK: https://github.com/IHP-GmbH/IHP-Open-PDK
El PDK y herramientas están dentro de la imagen y mantienen sus propias licencias.
Se omite el submódulo antiguo del curso para no tener dos PDK distintos activos.

Para cambiar versiones: modificar el lock en una rama, ejecutar el diagnóstico
y revisar resultados antes de integrar. No sustituir el digest por `latest`.
La reproducción depende de que el registro siga ofreciendo esta imagen.
